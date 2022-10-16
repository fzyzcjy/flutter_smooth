# FPS is 30 (not 59) when 16.67+0.01ms

It will immediately drop to 30FPS even if the frame is only 0.01ms longer than 16.67ms. Indeed this problem is unrelated to this package, because the proposed method will **not** be affected by this and will be (e.g.) 59FPS. However, it may be helpful to discuss here to avoid wrongly understand the metrics of the classical Flutter and other optimization methods.

To simplify math, suppose each frame needs 16.67+0.01ms and continue for one second. Then, classical Flutter (and some other optimization approaches discussed in the [design doc](https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit#heading=h.enm17io2vqom)) will miss half of the vsync, i.e. will only get vsync per 33.33ms. Therefore, they will simply run the pipeline per 33.33ms, which is 30FPS.

Remark: The “average FPS” in DevTools [seems to be wrong](https://github.com/flutter/devtools/issues/4522) for such cases.

Remark: Given this discussion, when reading something like “17ms” in the “`*_frame_build_time_millis`” in benchmark results, it indeed means a completely different end-user feeling (30FPS vs 59FPS).

:::caution

Takeaway:

1. Do not believe `average FPS` in DevTools.
2. `*_frame_build_time_millis` being something like "17ms", means 30FPS, not 59FPS.

:::

(Firstly discussed in the [design doc](https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit#heading=h.enm17io2vqom))