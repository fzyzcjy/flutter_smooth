import json
import re
from argparse import ArgumentParser
from pathlib import Path
from typing import Callable, Dict
from zipfile import ZipFile

parser = ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()

path_input = Path(args.input)
path_output = path_input.parent / f'{path_input.stem}_enhanced.json'
path_output_zipped = path_output.parent / f'{path_output.name}.zip'

data = json.loads(path_input.read_text())
new_events = []


def synthesize_long_event(old_event: Dict, synthesize_tid: int, synthesize_duration_us=10000):
    global new_events

    ts = old_event['ts']
    common_args = dict(
        tid=synthesize_tid,
        name=old_event['name'],
        cat=old_event['cat'],
        pid=old_event['pid'],
    )

    new_events += [
        dict(ts=ts, ph='B', **common_args),
        dict(ts=ts + synthesize_duration_us, ph='E', **common_args),
    ]


def synthesize_long_event_matching_filter(filter_event: Callable[[str], bool], synthesize_tid: int):
    for e in data['traceEvents']:
        if e['ph'] == 'B' and filter_event(e['name']):
            synthesize_long_event(e, synthesize_tid=synthesize_tid)


synthesize_long_event_matching_filter(
    lambda s: re.match(r'.*\.S\.SimpleCounter', s) is not None,
    synthesize_tid=-999999,
)

print(f'#old-events={len(data["traceEvents"])} #new-events={len(new_events)}')
path_output.write_text(json.dumps({
    **data,
    'traceEvents': data['traceEvents'] + new_events,
}))

with ZipFile(path_output_zipped, 'w') as zipf:
    zipf.write(path_output, arcname=path_output.name)
