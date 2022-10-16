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

    def inflate_horizontal(self, left, right):
        return Bbox(
            self.x - left,
            self.y,
            self.w + left + right,
            self.h,
        )

    @property
    def xywh(self):
        return [self.x, self.y, self.w, self.h]


plain_bbox = Bbox.from_p1_p2((340, 0), (960, 1050))
smooth_bbox = Bbox.from_p1_p2((230, 0), (840, 1050))

# to tinker the numbers, use things like:
# `ffplay -vf eq=gamma=1.5:saturation=1.3 blob/video/output.mp4`
# https://video.stackexchange.com/questions/20962/ffmpeg-color-correction-gamma-brightness-and-saturation
eq_filter = dict(gamma=1.8, contrast=1.2)

p_output = dir_video / 'output.mp4'
p_output.unlink(missing_ok=True)

in_plain = ffmpeg.input(str(dir_video / 'list_view/raw_plain.mp4'))
in_smooth = ffmpeg.input(str(dir_video / 'list_view/raw_smooth.mp4'))


def crop_and_pad(s, bbox: Bbox, *, left, right):
    s = ffmpeg.crop(s, *bbox.inflate_horizontal(left=left, right=right).xywh)
    # s = ffmpeg.drawbox(s, *Bbox(x=0, y=0, w=left, h=bbox.h).xywh, 'white', thickness=left)
    # s = ffmpeg.drawbox(s, *Bbox(x=left + bbox.w, y=0, w=right, h=bbox.h).xywh, 'white', thickness=right)
    return s


cropped_plain = crop_and_pad(in_plain, plain_bbox, left=100, right=50)
cropped_smooth = crop_and_pad(in_smooth, smooth_bbox, left=50, right=100)

stream = ffmpeg.filter([cropped_plain, cropped_smooth], "hstack", inputs=2)
stream = ffmpeg.filter([stream], 'eq', **eq_filter)
stream = stream.output(str(p_output))
print(ffmpeg.compile(stream))
ffmpeg.run(stream)
