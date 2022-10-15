import json
import re
from argparse import ArgumentParser
from bisect import bisect_left
from pathlib import Path
from typing import Callable, List, Dict
from zipfile import ZipFile, ZIP_DEFLATED

from timeline.common import parse_vsync_positions, parse_raster_end_positions

TraceEvent = Dict

parser = ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()

path_input = Path(args.input)
path_output = path_input.parent / f'{path_input.stem}_enhanced.json'

data = json.loads(path_input.read_text())


class TimeConverter:
    def __init__(self, data):
        self.min_ts = min(e['ts'] for e in data['traceEvents'])

    def ts_to_relative_time(self, ts: int):
        return ts - self.min_ts

    def format_time(self, ts: int):
        relative_time = self.ts_to_relative_time(ts)
        return relative_time / 1000000


time_converter = TimeConverter(data)


def synthesize_event(
        *,
        name: str,
        start_us: int,
        tid: int,
        duration_us: int = 10000,
        logging=False,
) -> List[TraceEvent]:
    if logging:
        print(f'Event: {name} @ {time_converter.format_time(start_us)} ~ +{duration_us / 1000000}')

    common_args = dict(
        tid=tid,
        name=name,
        cat='synthesized',
        pid=-1000000,
    )

    return [
        dict(ts=start_us, ph='B', **common_args),
        dict(ts=start_us + duration_us, ph='E', **common_args),
    ]


def synthesize_long_event_matching_filter(filter_event: Callable[[str], bool], synthesize_tid: int):
    new_events = []
    for e in data['traceEvents']:
        if e['ph'] == 'B' and filter_event(e['name']):
            new_events += synthesize_event(
                name=e['name'],
                start_us=e['ts'],
                tid=synthesize_tid,
            )
    return new_events


ABNORMAL_TID = -999999


def synthesize_events_abnormal_vsync_duration(vsync_positions: List[int]):
    normal_value = 16667
    threshold = 1000

    vsync_positions = sorted(vsync_positions)

    new_events = []

    for vsync_index in range(len(vsync_positions) - 1):
        delta = vsync_positions[vsync_index + 1] - vsync_positions[vsync_index]
        if abs(delta - normal_value) > threshold:
            new_events += synthesize_event(
                name='AbnormalVsyncDuration',
                start_us=vsync_positions[vsync_index],
                duration_us=100 * 1000,
                tid=ABNORMAL_TID - 1,
                logging=True,
            )

    return new_events


def synthesize_events_abnormal_raster_in_vsync_interval(vsync_positions: List[int], raster_end_positions: List[int]):
    new_events = []
    raster_index = 0
    for vsync_index in range(len(vsync_positions) - 1):
        num_raster_in_vsync_interval = 0
        while raster_index < len(raster_end_positions) and \
                raster_end_positions[raster_index] < vsync_positions[vsync_index + 1]:
            raster_index += 1
            num_raster_in_vsync_interval += 1

        if raster_index >= len(raster_end_positions):
            break

        event_common_args = dict(
            start_us=vsync_positions[vsync_index],
            duration_us=vsync_positions[vsync_index + 1] - vsync_positions[vsync_index],
            tid=ABNORMAL_TID,
            logging=True,
        )
        if num_raster_in_vsync_interval == 0:
            new_events += synthesize_event(name='Jank(ZeroRasterEndInVsyncInterval)', **event_common_args)
        elif num_raster_in_vsync_interval >= 2:
            new_events += synthesize_event(name='Waste(MultiRasterEndInVsyncInterval)', **event_common_args)
    return new_events


def synthesize_events_no_pending_continuation(vsync_positions: List[int]):
    new_events = []
    for e in data['traceEvents']:
        # this event only exist in our modified code, NOT in master code (yet) in 2022.10.10
        if e['name'] == 'NoPendingContinuation' and e['ph'] == 'B':
            vsync_index = bisect_left(vsync_positions, e['ts']) - 1
            if vsync_index >= len(vsync_positions) - 1:
                continue
            new_events += synthesize_event(
                name='Waste(NoPendingContinuation)',
                start_us=vsync_positions[vsync_index],
                duration_us=vsync_positions[vsync_index + 1] - vsync_positions[vsync_index],
                tid=ABNORMAL_TID,
            )
    return new_events


# this is defined as `PreemptStrategyNormal.kActThresh` in .dart, keep in sync with there!
PREEMPT_RENDER_DELTA = 2 * 1000


def synthesize_events_preempt_render_large_latency(vsync_positions: List[int]):
    new_events = []
    for e in data['traceEvents']:
        if not (e['name'] == 'PreemptRender' and e['ph'] == 'B'):
            continue

        reason = e.get('args', {}).get('reason')
        # AfterDrawFrame is triggerred not near vsync, but can be in arbitrary location
        if reason == 'AfterDrawFrame':
            continue

        actual_preempt_render_time = e['ts']
        interest_vsync_index = bisect_left(vsync_positions, actual_preempt_render_time + 8000) - 1
        expect_preempt_render_time = vsync_positions[interest_vsync_index] - PREEMPT_RENDER_DELTA

        threshold = 2500

        if actual_preempt_render_time > expect_preempt_render_time + threshold:
            new_events += synthesize_event(
                name='LargeLatency_PreemptRender',
                start_us=expect_preempt_render_time,
                duration_us=10000,
                tid=-999998,
            )
    return new_events


def main():
    vsync_positions = parse_vsync_positions(data)
    raster_end_positions = parse_raster_end_positions(data)

    data['traceEvents'] += synthesize_events_abnormal_vsync_duration(vsync_positions)
    data['traceEvents'] += synthesize_events_abnormal_raster_in_vsync_interval(vsync_positions, raster_end_positions)
    data['traceEvents'] += synthesize_events_no_pending_continuation(vsync_positions)
    data['traceEvents'] += synthesize_events_preempt_render_large_latency(vsync_positions)

    data['traceEvents'] += synthesize_long_event_matching_filter(
        lambda s: re.match(r'.*\.S\.SimpleCounter', s) is not None, synthesize_tid=-999997)

    print(f'#events={len(data["traceEvents"])}')
    path_output.write_text(json.dumps(data))

    with ZipFile(f'{path_input}.zip', 'w', compression=ZIP_DEFLATED) as zipf:
        zipf.write(path_input, arcname=path_input.name)


if __name__ == '__main__':
    main()
