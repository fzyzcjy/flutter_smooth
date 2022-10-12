from bisect import bisect_left
from typing import List


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


def find_before(data, index_start, predicate):
    for index in range(index_start, -1, -1):
        if predicate(index, data['traceEvents'][index]):
            return index
    raise Exception('not found')


def parse_frame_infos(data):
    """#6150"""

    vsync_positions = parse_vsync_positions(data)

    for index_rasterizer_end, e_rasterizer_end in enumerate(data['traceEvents']):
        if not (e_rasterizer_end['ph'] == 'E' and e_rasterizer_end['name'] == 'GPURasterizer::Draw'):
            continue

        index_flow_end = find_before(
            data, index_rasterizer_end - 1,
            lambda i, e: e['name'] == 'PipelineItem' and e['ph'] == 'f')
        flow_id = data['traceEvents'][index_flow_end]['id']
        index_flow_start = find_before(
            data, index_flow_end - 1,
            lambda i, e: e['name'] == 'PipelineItem' and e['ph'] == 's' and e['id'] == flow_id)
        index_window_render_start = find_before(
            data, index_flow_start - 1,
            lambda i, e: e['name'] == 'window.render')
        e_window_render_start = data['traceEvents'][index_window_render_start]

        ts_rasterizer_end = e_rasterizer_end['ts']

        # https://github.com/fzyzcjy/yplusplus/issues/6154#issuecomment-1275505377
        i = bisect_left(vsync_positions, ts_rasterizer_end)
        if i < len(vsync_positions):
            display_screen_time = vsync_positions[i]
            assert display_screen_time - 16667 <= ts_rasterizer_end <= display_screen_time
        else:
            display_screen_time = vsync_positions[-1]  # fallback

        yield dict(
            ts_window_render=e_window_render_start['ts'],
            display_screen_time=display_screen_time,
            ts_rasterizer_end=ts_rasterizer_end,
            index_window_render_start=index_window_render_start,
        )


def is_enclosed_by(data, self_index, enclose_predicate):
    for index in range(self_index - 1, -1, -1):
        e = data['traceEvents'][index]
        if enclose_predicate(e):
            assert e['ph'] in ('B', 'E')
            return e['ph'] == 'B'
    return False
