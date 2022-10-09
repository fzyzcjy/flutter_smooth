import json
from argparse import ArgumentParser
from pathlib import Path
from zipfile import ZipFile

parser = ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()

path_input = Path(args.input)
path_output = path_input.parent / f'{path_input.stem}_enhanced.json'
path_output_zipped = path_output.parent / f'{path_output.name}.zip'

data = json.loads(path_input.read_text())

# TODO

path_output.write_text(json.dumps(data))

with ZipFile(path_output_zipped, 'w') as zipf:
    zipf.write(path_output, arcname=path_output.name)
