# Remove (3N-1) uncomfort

:::info Upstream PR

**Title:** Remove (3N-1) jank and big-jump when N rasterization misses deadline

**Link**: https://github.com/flutter/engine/pull/36912

:::

<!-- see #6306 -->

This optimization holds for both classical Flutter and flutter_smooth - indeed the figure below is for classical Flutter.

In experiments, I do see rasterization takes longer time once in a while, instead of having the exact same duration. Experiments show that, a portion of rasterization ends a little bit later than the deadline (the vsync), while all others meet the deadline.

The following figure demonstrates the case. Given that this code change is unrelated to flutter_smooth, the scenario assumes UI is fast and no flutter_smooth exist at all. If using flutter_smooth, things are similar indeed. The first row is the case without code change to `animator.cc`, and the second row is the case with (1) this change (2) plus the https://github.com/flutter/engine/pull/36837 change.

```mdx-code-block
import RasterizerQueueJank from '@site/static/svg/rasterizer_queue_jank.svg'

<center><RasterizerQueueJank/></center>
```

Consider the frame starting at time 1. In the first row, when the rasterization misses the deadline a little bit (seen in time 2-3), there is nothing new to be shown to the screen, so time 2-3 yields a jank. This is inevitable and also holds for the second row - indeed the only jank in the second row.

Now consider the frame starting at time 2. It yields a big jump in classical Flutter, because the scene "1" (rasterized at about time 3.1) never has a chance to be shown to the screen. The second row does not have the problem because of the deliberate sleep.

Then comes the frame starting at time 3. In classical Flutter, the `Animator::BeginFrame` early returns, and thus no Dart pipeline is run, because it detects the pipeline is full. The pipeline is full because it is occupied with both the frame around 1-3.1 and the frame around 2-3.9. However, we are too pessimisitic about this - even though the pipeline is full at the *beginning* of BeginFrame, it may not be full at the *end* when we really need to call `Animator::Render` and enqueue a real scene to rasterizer. Thus, the classical Flutter (row 1) voluntarily give up a whole frame causing a jank, while the proposed solution runs the normal pipeline and produce a new scene.

Next is the frame starting at time 4, which we again assume its rasterization misses the deadline a little bit. All frames starting at this one indeed mimics the analysis above, so we do not repeate here. The interesting thing is that, the proposed solution *no longer* yields a jank anymore.

So, if we count the numbers, there are 3N janks in the first row (where N is the number of slightly missing deadline), and only 1 jank in the second row.

The drawback is that, the latency is increased by one frame, until the end of current frame chain (such as when animation finally finishes). However, when scrolling or touching, this seems better than having a large annoying jump in the UI - which is directly perceptible by human eyes easily. My test mobile phone has intrinsic (i.e. OS/hardware constraints) touch event latency of about 100ms, so adding 16ms to it looks almost non-distinguishable. Of course, if someone is developing a game, having low latency may be more important.

The same analysis also holds for any "latency changes from 2 to 3 to 2" scenario. For example, the "latency being 3" may last for more than one frame (contrary to the figure), with flutter_smooth.

As a remark, flutter_smooth is indeed implicitly doing something similar when *in the middle of* a plain jank frame. As we know, when a preempt render is about to start (analogy to "when `Animator::BeginFrame` is called"), we never skip it if pipeline is full (analyogy to the code change to BeginFrame). This works well in experiments.

P.S. Indeed, this is not something caused by flutter_smooth (since it is *rasterizer* slowness instead of build/layout slowness), but I have found a way trying to improve it.