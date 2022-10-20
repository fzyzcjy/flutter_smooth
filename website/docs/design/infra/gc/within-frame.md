# Within-frame

:::info

The following are mainly copied from https://github.com/flutter/engine/pull/36797

:::

It is necessary for https://github.com/fzyzcjy/flutter_smooth because of the following commonly seen scenario: Suppose we are in a janky frame (say it takes 200ms). Then, NotifyIdle is *never* called at all, because it is usually called at the end of DrawFrame (indeed, more exactly, in the Animator::AwaitVSync). Then, during the 200ms, garbage accumulates, and at one time the young generation is full, then Dart VM must stop the world and make a GC. From my experiments, such GC can even take 20ms on my testing device. Stop the world for 20ms - then we must miss one frames, causing non-60FPS. Even if the stop-the-world GC is fast, say, 5ms, it can still cause a jank. For example, when it happens at 97.5ms-102.5ms, then the preemptRender which should originally be done near 98-100ms can only be done at 105ms, so it calls window.render too late, thus the rasterizer may fail to rasterize the frame before the 116.67ms vsync, so there is a jank. (If needed, I can draw a figure).

However, with this PR, there is no such problem at all. The flutter_smooth will call NotifyIdle immediately *after* each and every preemptRender, with a deadline of roughly 14ms (16.67ms minus a few ms). By doing this, there are two benefits. Firstly, since the heap is not that full, GC can finish its work sooner instead of the 20ms bad case when the heap is really full. This avoids the 20ms-long-GC problem above. Secondly, since we actively tell Dart VM that it can start a GC at *this* time, GC can run for a time duration as long as ~14ms without causing any jank. This is contrary to the discussion above, where even a 5ms GC can cause a frame jank. As for why it can run 14ms without causing trouble, it is because, suppose we start it at 100ms and it runs 14ms, then we are now at 114ms, and we start preemptRender. Since preemptRender is really fast (e.g. 2ms), we will submit window.render at 116ms. In other words, we submit window.render with sufficient time left for rasterizer to finish its job - as long as rasterizer finishes its job before 133.33ms, no jank will happen.

Therefore, the title is explained well: It allows `flutter_smooth` to get 60FPS, even if GC needs to run for 14ms per 16.67ms. (That extreme GC will not happen in real world, I just want to say this proposal works even for that.)

I have already done that for my engine branch and ran experiments on flutter_smooth. It works pretty well - originally I observe GC-caused janks and then they disappear after this fix. If you are interested I can present some data.