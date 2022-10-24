# Between-frame

:::info

The following are mainly copied from https://github.com/flutter/engine/pull/36834

:::

This PR is similar to https://github.com/flutter/engine/pull/36797. However, it addresses another portion of the GC-caused-jank problem.

Consider the following case: For each frame, UI thread needs to run for 16.00ms. Then:

**Without this PR and without flutter_smooth**: We know NotifyIdle will be called after the frame ends (more specifically, at AwaitVSync), and the "deadline" argument of NotifyIdle is set to "next_vsync_time - current_time". In other words, it is 16.67-16=0.67ms in our scenario. When DartVM receives this NotifyIdle call, it estimates how long a young GC needs, and realize it needs more than 0.67ms, so it do not call any young GC here. Therefore, garbage starts to accumulate. Finally, at one time, (young) GC must happen because the heap is full. At that time, Dart VM will stop the world for (e.g.) 10ms. Given that the UI thread needs 16.00ms to compute the content of one frame, the 10ms stop-the-world means it must miss at least one deadline. Thus, it janks whenever GC comes.

**With this PR and flutter_smooth**: No such problem at all. Let's consider one specific frame. Suppose the UI thread runs from 0.00-16.00ms and finished computing the content. Then, when calling NotifyIdle, I will deliberately set the "deadline" to be "next_vsync_time - current_time + 14ms". In other words, DartVM is now notified that, it has 14.67ms (instead of 0.67ms as before). Given this loose deadline, Dart VM happily executes a young GC (when it feels needed) using (e.g.) 10ms. Now we are at 26.00ms and the next frame begins. Given that we are using flutter_smooth, we can easily deliver an extra smooth frame when needed near 33.33ms, even though the plain-old frame needs 16.00ms to compute. Therefore, GC is triggered at proper time that does not cause any jank. And since NotifyIdle is triggered per 16.67ms with sufficient deadline (>14ms deadline duration), Dart VM will do GC at these period, so there will be no GC mentioned in the previous case which happens at random location causing UI to jank.

In conslusion, this PR allows `flutter_smooth` to get 60FPS, even if GC needs to run for (e.g.) 14ms per 16.67ms.