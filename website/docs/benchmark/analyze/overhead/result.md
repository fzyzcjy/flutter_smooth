# Result

:::caution

The `MaybePreemptRender` is slow (needs syscall) now, causing larger overhead. It can be (and should be) optimized: https://github.com/fzyzcjy/flutter_smooth/issues/110. The pipeline is also not optimized yet.

:::

The possible overhead components may be:

1. `MaybePreemptRender` checks - overhead. In each preempt point, we have to check whether it is time to trigger a preempt render.
2. Preempt render - not overhead. To my best knowledge, any solution that wants to achieve 60FPS has to run the build/layout/paint/etc pipeline for the part that wants to be changing. Therefore, it is inevitable to have this component. (Feel free to correct me if you come up with a faster solution without that.) By the way, this part strongly depends on your use case. If you have simple animations this will be fast, while for extremely fancy animations it can be slow.

Thus, the question remains to be, how slow is `MaybePreemptRender` checks?

I [originally checked it](https://github.com/fzyzcjy/flutter_smooth/commit/d9cc91ff61fa560b385fffa3f0461b0d3226df1a) by adding a Timeline event whenever a MaybePreemptRender is called, and by using the `overhead.py`, the average of one such check is 22.57 microseconds on my machine. In other words, since (by looking at tracing data) we call it roughly once per millisecond, it is 2.3% overhead. However, this is wrong. The `Timeline.timeSync` itself has non-neglitible overhead, as it itself reads system time twice (i.e. two syscalls), while the code under measurement is nothing but *one* read-system-time (i.e. one syscall). From such rough estimation, it should be less than 2.3/3 = 0.8% overhead.

Anyway, in my humble opinion any number lower than 2.3% looks already good enough, so I will firstly spend time doing other work in this library. Feel free to PR for an accurate measurement of overhead!

<small>(To reproduce this, create your own tracing data using latest code, instead of using the sample tracing json in this repo - I recorded that prior to writing this section and that data does not include MaybePreemptRender timeline events.)</small>
