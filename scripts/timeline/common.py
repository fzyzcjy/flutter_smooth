from dataclasses import dataclass
from typing import List, Iterable


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


@dataclass
class FrameInfo:
    ts_window_render: int
    vsync_target_time: int
    ts_rasterizer_end: int


def parse_frame_infos(data) -> Iterable[FrameInfo]:
    """#6150"""

    def _find_before(index_start, predicate):
        for index in range(index_start, -1, -1):
            if predicate(data['traceEvents'][index]):
                return index
        raise Exception('not found')

    for index_rasterizer_end, e_rasterizer_end in enumerate(data['traceEvents']):
        if not (e_rasterizer_end['ph'] == 'E' and e_rasterizer_end['name'] == 'GPURasterizer::Draw'):
            continue

        index_flow_end = _find_before(index_rasterizer_end - 1,
                                      lambda e: e['name'] == 'PipelineItem' and e['ph'] == 'f')
        flow_id = data['traceEvents'][index_flow_end]['id']
        index_flow_start = _find_before(index_flow_end - 1,
                                        lambda e: e['name'] == 'PipelineItem' and e['ph'] == 's' and e['id'] == flow_id)
        index_window_render_start = _find_before(index_flow_start - 1,
                                                 lambda e: e['name'] == 'window.render')
        e_window_render_start = data['traceEvents'][index_window_render_start]

        yield FrameInfo(
            ts_window_render=e_window_render_start['ts'],
            vsync_target_time=int(e_window_render_start['effectiveFallbackVsyncTargetTime']),
            ts_rasterizer_end=e_rasterizer_end['ts'],
        )
