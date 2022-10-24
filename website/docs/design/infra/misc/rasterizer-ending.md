# Fix rasterizer ending time

:::info

**Title**: "Fix jank and large-jumping frame by controlling rasterizer ending time"

**Link**: https://github.com/flutter/engine/pull/36837

:::

Consider the problem - what will happen, when the computation latency becomes lower temporarily? Looks like it is a good thing, since faster means better; many FPS monitors also do not think this is a problem. Spoiler: It is a bad thing - pay a jank.

Detailed analysis is as follows. To begin with, let us define "latency" as the number of frames it takes from starting drawing frame to ending rasterization. Now, what happens when latency temporarily drops to 1 for one or some frames, while it is 2 in other frames? This is separted to two parts: latency decrease (2->1) and increase (1->2).

The decrease itself does not introduce jank, but causes a uncomfortable "jumping" feeling from the user (will be discussed in the "linearlity" section later). For example, say frame a (0.00-16.67ms) has latency 2, frame b (16.67-33.33ms) has latency 2, and frame c (33.33-50.00ms) has latency 1. Then, at 33.33ms, content of frame a is displayed. However, at 50.00ms, both the content from frame b and frame c wants to be displayed to screen, so frame b will never be shown and only frame c is shown. If it is a linear moving animation with 1px per millisecond, we will see offset being 0 (frame a) at 33.33ms and offset being 33.33px (frame c) at 50.00ms, while we know all other frames will introduce an offset of 16.67px per frame. Thus a big jump happens.

As for the increase (1->2), it will introduce one jank. Suppose frame 0.00-16.67ms has latency 1, and 16.67-33.33ms has latency 2. Then, the rasterizer will provide new content to screen only at 16.67ms and 50.00ms, not at 33.33ms, and there is a jank.

Similar analysis holds for any latency change. For example, "1->2->1" latency change will cause a jank and then a uncomfortable big-jump.

Does this happen in real world? Yes, and quite frequently! I do observe it a lot of times in my tracing timeline. For example, the UI+rasterizer time may be *near* 16.67ms with fluctuation, then we do see a lot of 1->2 / 2->1 latency change. As another example, sometimes a frame may be much faster or slower to compute.

That is what this PR solves. Let's discuss by concrete numbers. Suppose latency is always 2 for a lot of frames, and suddenly in this frame latency drop to 1. Then, this PR will delay the rasterizer ending by sleeping (or can be changed to signaling or whatever you like). It will sleep (shortly speaking) to the next vsync, such that after the sleep, this frame has latency 2. No worries if the sleep happens to be a bit longer - it is still latency 2 if that happens.

Related: https://cjycode.com/flutter_smooth/benchmark/pitfall/latency-change