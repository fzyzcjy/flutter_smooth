try:
    get_ipython().magic('%load_ext autoreload')
    get_ipython().magic('%autoreload 2')
except:
    pass  # ignore

import matplotlib

matplotlib.use("MacOSX")

import numpy as np
import json
from pathlib import Path
from typing import Dict

import matplotlib.pyplot as plt
import pandas as pd
from timeline.common import parse_frame_infos

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
df_frame = pd.DataFrame(parse_frame_infos(data))

scroll_controller_offsets = pd.DataFrame([
    dict(ts=e['ts'], offset=e['args']['offset']) for e in data['traceEvents']
    if e['ph'] == 'B' and e['name'] == 'ScrollController.listener'
]).sort_values('ts')
smooth_shift_offsets = pd.DataFrame([
    dict(ts=e['ts'], offset=e['args']['offset']) for e in data['traceEvents']
    if e['ph'] == 'B' and e['name'] == 'SmoothShift'
]).sort_values('ts')

min_ts = min(e['ts'] for e in data['traceEvents'])


def _transform_ts(ts):
    return (ts - min_ts) / 1000000


def _compute_smooth_shift(row):
    i = smooth_shift_offsets.ts.searchsorted(row.ts_window_render) - 1
    if i < 0: return 0
    return smooth_shift_offsets.offset[i]


def _compute_scroll_controller_offset_nearest(row):
    i = scroll_controller_offsets.ts.searchsorted(row.ts_window_render) - 1
    if i < 0: return 0
    return scroll_controller_offsets.offset[i]


df_frame['smooth_shift_offset'] = df_frame.apply(_compute_smooth_shift, axis=1)
df_frame['scroll_controller_offset_nearest'] = df_frame.apply(_compute_scroll_controller_offset_nearest, axis=1)

plt.clf()
plt.tight_layout()

plt.scatter(_transform_ts(scroll_controller_offsets.ts), scroll_controller_offsets.offset,
            s=2, label='ScrollController', c='C3')
plt.scatter(_transform_ts(smooth_shift_offsets.ts), smooth_shift_offsets.offset,
            s=2, label='Smooth', c='C4')
# plt.vlines(vsync_positions, -300, 300, linewidths=.1, label='Vsync')

plt.plot(_transform_ts(df_frame.vsync_target_time),
         df_frame.scroll_controller_offset_nearest - df_frame.smooth_shift_offset,
         '-o', markersize=2, label='offset nearest')
plt.plot(np.array(_transform_ts(df_frame.vsync_target_time)[:-1]),
         np.array(df_frame.scroll_controller_offset_nearest[1:]) - np.array(df_frame.smooth_shift_offset[:-1]),
         '-o', markersize=2, label='offset alternative')

plt.legend(loc="upper left")
plt.show()
