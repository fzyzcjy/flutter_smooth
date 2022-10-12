import matplotlib

matplotlib.use("MacOSX")

import json
from pathlib import Path
from typing import Dict

import matplotlib.pyplot as plt
import pandas as pd

from timeline.common import parse_vsync_positions, parse_raster_end_positions

TraceEvent = Dict

if 0:
    parser = ArgumentParser()
    parser.add_argument('input')
    args = parser.parse_args()
    path_input = args.input
else:
    path_input = '/Users/tom/Downloads/dart_devtools_2022-10-12_08_07_05.896.json'

# %%

data = json.loads(Path(path_input).read_text())
vsync_positions = parse_vsync_positions(data)
raster_end_positions = parse_raster_end_positions(data)

scroll_controller_offsets = pd.DataFrame([
    dict(ts=e['ts'], offset=e['args']['offset']) for e in data['traceEvents']
    if e['ph'] == 'B' and e['name'] == 'ScrollController.listener'
])
smooth_shift_offsets = pd.DataFrame([
    dict(ts=e['ts'], offset=e['args']['offset']) for e in data['traceEvents']
    if e['ph'] == 'B' and e['name'] == 'SmoothShift'
])

plt.clf()
plt.tight_layout()
plt.scatter(scroll_controller_offsets.ts, scroll_controller_offsets.offset, s=1, label='ScrollController')
plt.scatter(smooth_shift_offsets.ts, smooth_shift_offsets.offset, s=1, label='Smooth')
# plt.vlines(vsync_positions, -300, 300, linewidths=.1, label='Vsync')
plt.legend(loc="upper left")
plt.show()
