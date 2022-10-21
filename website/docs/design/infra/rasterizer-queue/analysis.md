# Analysis

What problem will we have, given the original Flutter engine described above?

## Allow multi-render in one plain frame

It is a must to add that change (create a continuation if there is none) to `Render`. This is because, we call `Render` multiple times for one `BeginFrame`. The original code will reject all `Render`s except for the first one, thus the whole flutter_smooth will not work because we can no longer submit anything more to render.

## Only pay 1 jank when N rasterization misses deadline

<!-- see #6306 -->

In experiments, I do see rasterization takes longer time once in a while, instead of having the exact same duration. Therefore, experiments show that, sometimes one rasterization ends a little bit later than the deadline (the vsync), while all others work well. Indeed, this is not something caused by flutter_smooth (since it is *rasterizer* slowness instead of build/layout slowness), but I have found a way trying to improve it.

The following figure demonstrates the case. Given that this code change is unrelated to flutter_smooth, the scenario assumes UI is fast and no flutter_smooth exist at all. (If using flutter_smooth, things are similar indeed.) The first row is the case without code change to `animator.cc`, and the second row is the case with this change plus the https://github.com/flutter/engine/pull/36837.

```mdx-code-block
import RasterizerQueueJank from '@site/static/svg/rasterizer_queue_jank.svg'

<center><RasterizerQueueJank/></center>
```

In the figure, it just makes 2 janks into one. However, in real world, there can be (e.g.) 10 janks without this fix, and again only one with the fix.

TODO: explain

TODO explain "Only pay one jank when arbitrary number of rasterization misses deadline'"

The drawback is that, the latency is increased by one frame, until the end of current frame chain (such as when animation finally finishes). However, when scrolling or touching, this seems better than having a large annoying jump in the UI - which is directly perceptible by human eyes easily. My test mobile phone has intrinsic (i.e. OS/hardware constraints) touch event latency of about 100ms, so adding 16ms to it looks almost non-distinguishable. Of course, if someone is developing a game, having low latency may be more important.

The same analysis also holds for any "latency changes from 2 to 3 to 2" scenario. For example, the "latency being 3" may last for more than one frame (contrary to the figure), with flutter_smooth.

As a remark, flutter_smooth is indeed implicitly doing something similar when *in the middle of* a plain jank frame. As we know, when a preempt render is about to start (analogy to "when `Animator::BeginFrame` is called"), we never skip it if pipeline is full (analyogy to the code change to BeginFrame). This works well in experiments.