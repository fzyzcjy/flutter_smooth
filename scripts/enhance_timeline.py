import json
import re
from argparse import ArgumentParser
from pathlib import Path
from typing import Callable, List, Dict
from zipfile import ZipFile

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


def parse_vsync_positions(data) -> List[int]:
    return sorted([
        e['ts'] for e in data['traceEvents']
        if e['ph'] == 'B' and e['name'] == 'VSYNC'
    ])


def parse_raster_end_positions(data) -> List[int]:
    return sorted([
        e['ts'] for e in data['traceEvents']
        if e['ph'] == 'E' and e['name'] == 'GPURasterizer::Draw'
    ])


ABNORMAL_TID = -999999


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


def main():
    vsync_positions = parse_vsync_positions(data)
    raster_end_positions = parse_raster_end_positions(data)

    data['traceEvents'] += synthesize_events_abnormal_raster_in_vsync_interval(vsync_positions, raster_end_positions)

    data['traceEvents'] += synthesize_long_event_matching_filter(
        lambda s: re.match(r'.*\.S\.SimpleCounter', s) is not None, synthesize_tid=-999998)

    print(f'#events={len(data["traceEvents"])}')
    path_output.write_text(json.dumps(data))

    with ZipFile(f'{path_input}.zip', 'w') as zipf:
        zipf.write(path_input, arcname=path_input.name)


if __name__ == '__main__':
    main()
