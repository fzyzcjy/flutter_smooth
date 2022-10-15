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

    min_ts = min(e['ts'] for e in data['traceEvents'])
    vsync_positions = parse_vsync_positions(data)

    for index_rasterizer_end, e_rasterizer_end in enumerate(data['traceEvents']):
        if not (e_rasterizer_end['ph'] == 'E' and e_rasterizer_end['name'] == 'GPURasterizer::Draw'):
            continue

        index_flow_end = find_before(
            data, index_rasterizer_end - 1,
            lambda i, e: e['name'] == 'PipelineItem' and e['ph'] == 'f')
        flow_id = data['traceEvents'][index_flow_end]['id']
        index_flow_step = find_before(
            data, index_flow_end - 1,
            # NOTE must be "t" not "s"
            # https://github.com/fzyzcjy/yplusplus/issues/6154#issuecomment-1275522246
            lambda i, e: e['name'] == 'PipelineItem' and e['ph'] == 't' and e['id'] == flow_id)
        index_window_render_start = find_before(
            data, index_flow_step - 1,
            lambda i, e: e['name'] == 'window.render' and e['ph'] == 'B')
        e_window_render_start = data['traceEvents'][index_window_render_start]

        ts_window_render = e_window_render_start['ts']
        ts_rasterizer_end = e_rasterizer_end['ts']

        # https://github.com/fzyzcjy/yplusplus/issues/6154#issuecomment-1275505377
        i = bisect_left(vsync_positions, ts_rasterizer_end)
        if i < len(vsync_positions):
            display_screen_time = vsync_positions[i]
            # https://github.com/fzyzcjy/yplusplus/issues/6227#issuecomment-1279728357
            if not (display_screen_time - 16667 * 1.1 <= ts_rasterizer_end <= display_screen_time):
                print(
                    'ts_rasterizer_end vs display_screen_time may look weird, or may be normal'
                    f'display_screen_time(relative)={display_screen_time - min_ts} '
                    f'ts_rasterizer_end(relative)={ts_rasterizer_end - min_ts}'
                )
        else:
            display_screen_time = vsync_positions[-1]  # fallback

        ans = dict(
            ts_window_render=ts_window_render,
            display_screen_time=display_screen_time,
            ts_rasterizer_end=ts_rasterizer_end,
            index_window_render_start=index_window_render_start,
        )

        # for debug
        # if abs(ts_rasterizer_end - (min_ts + 9.850 * 1000000)) < 4000 or \
        #         abs(ts_rasterizer_end - (min_ts + 9.835 * 1000000)) < 4000:
        #     print(
        #         'hi', ans,
        #         f'index_flow_end={index_flow_end}',
        #         f'flow_id={flow_id}',
        #         f'index_flow_step={index_flow_step}',
        #         f'e[index_flow_step].ts={data["traceEvents"][index_flow_step]["ts"] - min_ts}',
        #         f'index_window_render_start={index_window_render_start}',
        #         f'ts_window_render(relative)={ts_window_render - min_ts}',
        #         f'display_screen_time(relative)={display_screen_time - min_ts}',
        #         f'ts_rasterizer_end(relative)={ts_rasterizer_end - min_ts}',
        #     )

        yield ans


def is_enclosed_by(data, self_index, enclose_predicate):
    for index in range(self_index - 1, -1, -1):
        e = data['traceEvents'][index]
        if enclose_predicate(e):
            assert e['ph'] in ('B', 'E')
            return e['ph'] == 'B'
    return False
