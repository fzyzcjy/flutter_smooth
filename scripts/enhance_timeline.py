import json
import re
from argparse import ArgumentParser
from pathlib import Path
from typing import Callable, Dict, List, Tuple
from zipfile import ZipFile

parser = ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()

path_input = Path(args.input)
path_output = path_input.parent / f'{path_input.stem}_enhanced.json'

data = json.loads(path_input.read_text())

TraceEvent = Dict


def synthesize_event(
        *,
        name: str,
        start_us: int,
        tid: int,
        duration_us: int = 10000,
) -> List[TraceEvent]:
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
    data['traceEvents'] += new_events


VsyncRange = Tuple[int, int]


def parse_vsync_info() -> List[VsyncRange]:
    return TODO


def modify_vsync_events(vsync_ranges: List[VsyncRange]):
    # modify existing names
    for e in data['traceEvents']:
        if e['name'] == 'VSYNC':
            e['name'] = 'VSYNC_renamed'

    # add events
    data['traceEvents'] += [
        e
        for start, end in vsync_ranges
        for e in synthesize_event(
            name='VSYNC',
            start_us=start,
            duration_us=end - start,
            tid=-1000000,
        )
    ]


vsync_ranges = parse_vsync_info()
modify_vsync_events(vsync_ranges)

synthesize_long_event_matching_filter(
    lambda s: re.match(r'.*\.S\.SimpleCounter', s) is not None,
    synthesize_tid=-999998,
)

print(f'#events={len(data["traceEvents"])}')
path_output.write_text(json.dumps(data))

with ZipFile(f'{path_input}.zip', 'w') as zipf:
    zipf.write(path_input, arcname=path_input.name)
