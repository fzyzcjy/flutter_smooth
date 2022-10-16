from dataclasses import dataclass
from typing import Tuple

import ffmpeg

from utils import repo_base_dir

dir_video = repo_base_dir / 'blob/video'


@dataclass
class Bbox:
    x: int
    y: int
    w: int
    h: int

    @staticmethod
    def from_p1_p2(p1: Tuple[int, int], p2: Tuple[int, int]):
        x1, y1 = p1
        x2, y2 = p2
        return Bbox(x1, y1, x2 - x1, y2 - y1)

    @property
    def xywh(self):
        return [self.x, self.y, self.w, self.h]


plain_bbox = Bbox.from_p1_p2((200, 0), (1100, 1050))
smooth_bbox = Bbox.from_p1_p2((100, 0), (1000, 1050))

p_output = dir_video / '2_output.mp4'
p_output.unlink(missing_ok=True)

in_plain = ffmpeg.input(str(dir_video / '1_plain_raw.mp4'))
in_smooth = ffmpeg.input(str(dir_video / '1_smooth_raw.mp4'))

cropped_plain = ffmpeg.crop(in_plain, *plain_bbox.xywh)
cropped_smooth = ffmpeg.crop(in_smooth, *smooth_bbox.xywh)

stream = ffmpeg.filter(
    [cropped_plain, cropped_smooth],
    "hstack",
    inputs=2,
)
stream = stream.output(str(p_output))
print(ffmpeg.compile(stream))
ffmpeg.run(stream)
