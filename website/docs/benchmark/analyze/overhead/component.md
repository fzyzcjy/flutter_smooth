# Result from component

:::caution

The `MaybePreemptRender` is slow (needs syscall) now, causing larger overhead. It can be (and should be) optimized: https://github.com/fzyzcjy/flutter_smooth/issues/110. The pipeline is also not optimized yet.

:::

Let us discuss the possible overhead components:

1. `MaybePreemptRender` checks - overhead. In each preempt point, we have to check whether it is time to trigger a preempt render. Currently it is slow as it needs one syscall, but it can be (and should be) optimized in https://github.com/fzyzcjy/flutter_smooth/issues/110.
2. Preempt render - not overhead. To my best knowledge, any solution that wants to achieve 60FPS has to run the build/layout/paint/etc pipeline for the part that wants to be changing. Therefore, it is inevitable to have this component. (Feel free to correct me if you come up with a faster solution without that.) By the way, this part strongly depends on your use case. If you have simple animations this will be fast, while for extremely fancy animations it can be slow.

Thus, the question remains to be, how slow is `MaybePreemptRender` checks?

[TODO]

<small>(To reproduce this, create your own tracing data using latest code, instead of using the sample tracing json in this repo - I recorded that prior to writing this section and that data does not include MaybePreemptRender timeline events.)</small>
