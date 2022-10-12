try:
    get_ipython().magic('%load_ext autoreload')
    get_ipython().magic('%autoreload 2')
except:
    pass  # ignore

import matplotlib

matplotlib.use("MacOSX")

import json
from pathlib import Path
from typing import Dict
import numpy as np

import matplotlib.pyplot as plt
import pandas as pd
from timeline.common import parse_frame_infos, find_before, is_enclosed_by

TraceEvent = Dict

if 0:
    parser = ArgumentParser()
    parser.add_argument('input')
    args = parser.parse_args()
    path_input = args.input
else:
    path_input = '/Users/tom/Downloads/dart_devtools_2022-10-12_10_22_45.079.json'

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


def _compute_scroll_controller_offset(row):
    index_previous_non_preempt_render_paint = \
        find_before(data, int(row.index_window_render_start),
                    lambda i, e: e['name'] == 'PAINT' and e['ph'] == 'B'
                                 and not is_enclosed_by(data, i, lambda e: e['name'] == 'AuxTree.RunPipeline'))

    # the one *before* non-PreemptRender PAINT phase
    idx = scroll_controller_offsets.ts.searchsorted(
        data['traceEvents'][index_previous_non_preempt_render_paint]['ts']) - 1
    if idx < 0: return 0
    return scroll_controller_offsets.offset[idx]


df_frame['smooth_shift_offset'] = df_frame.apply(_compute_smooth_shift, axis=1)
df_frame['scroll_controller_offset'] = df_frame.apply(_compute_scroll_controller_offset, axis=1)
df_frame['felt_offset'] = df_frame.scroll_controller_offset - df_frame.smooth_shift_offset

plt.clf()
plt.tight_layout()
ax1 = plt.gca()

ax1.scatter(_transform_ts(scroll_controller_offsets.ts), scroll_controller_offsets.offset,
            s=2, label='ScrollController', c='C3')
ax1.scatter(_transform_ts(smooth_shift_offsets.ts), smooth_shift_offsets.offset,
            s=2, label='Smooth', c='C4')
# ax1.vlines(vsync_positions, -300, 300, linewidths=.1, label='Vsync')

ax1.plot(_transform_ts(df_frame.display_screen_time), df_frame.felt_offset, '-o', markersize=2, label='offset')

ax2 = ax1.twinx()
ax2.plot(_transform_ts(df_frame.display_screen_time)[:-1],
         np.array(df_frame.felt_offset[1:]) - np.array(df_frame.felt_offset[:-1]),
         '-o', markersize=2, label='delta(offset)', c='C1')

ax1.legend(loc="upper left")
ax2.legend(loc="upper right")

plt.show()
