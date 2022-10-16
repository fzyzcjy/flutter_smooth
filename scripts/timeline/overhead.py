import numpy as np

try:
    get_ipython().magic('%load_ext autoreload')
    get_ipython().magic('%autoreload 2')
except:
    pass  # ignore

import matplotlib

matplotlib.use("MacOSX")

from argparse import ArgumentParser
import json
from pathlib import Path
from typing import Dict

TraceEvent = Dict

parser = ArgumentParser()
parser.add_argument('input')
args = parser.parse_args()
path_input = args.input

# %%

data = json.loads(Path(path_input).read_text())

# just quite ugly script...
durations = []
pending_start_time = None
for e in data['traceEvents']:
    if e['name'] == 'MaybePreemptRender':
        if e['ph'] == 'B':
            pending_start_time = e['ts']
        elif e['ph'] == 'E' and pending_start_time is not None:
            end_time = e['ts']
            durations.append(end_time - pending_start_time)
            # print(pending_start_time, end_time)
            pending_start_time = None
    elif e['name'] == 'PreemptRender':
        pending_start_time = None

durations = np.array(durations)

print(
    f'avg_per_event={np.average(durations): .2f}us'
)
