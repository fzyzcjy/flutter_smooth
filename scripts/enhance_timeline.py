import json
import re
from argparse import ArgumentParser
from pathlib import Path
from typing import Callable
from zipfile import ZipFile

parser = ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()

path_input = Path(args.input)
path_output = path_input.parent / f'{path_input.stem}_enhanced.json'
path_output_zipped = path_output.parent / f'{path_output.name}.zip'

data = json.loads(path_input.read_text())


def synthesize_long_event(
        filter_event: Callable[[str], bool],
        synthesize_duration_us=10000,
        synthesize_tid=-999999,
):
    new_events = []

    for e in data['traceEvents']:
        if not (e['ph'] == 'B' and filter_event(e['name'])):
            continue

        ts = e['ts']
        common_args = dict(
            tid=synthesize_tid,
            name=e['name'],
            cat=e['cat'],
            pid=e['pid'],
        )

        new_events += [
            dict(ts=ts, ph='B', **common_args),
            dict(ts=ts + synthesize_duration_us, ph='E', **common_args),
        ]

    data['traceEvents'] += new_events


synthesize_long_event(lambda s: re.match(r'.*\.S\.SimpleCounter', s) is not None)

path_output.write_text(json.dumps(data))

with ZipFile(path_output_zipped, 'w') as zipf:
    zipf.write(path_output, arcname=path_output.name)
