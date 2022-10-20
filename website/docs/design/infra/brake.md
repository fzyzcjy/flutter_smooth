# Brake

## Why

Why do we need another mechanism, given that the Preempt already works well? Consider the following scenario: The user taps the screen (`PointerDownEvent`) in the middle of a long janky frame. More concretely, for example, when ListView is shifting quickly by inertia and during a long janky frame, the user drags the screen wanting to further scroll. As will be discussed in the [gesture](gesture) section, it is impossible to handle `PointerDownEvent` in the *middle* of a long janky frame. Therefore, if we only have the Preempt mechanism, we cannot respond to the user interaction until the janky frame ends.

Another example is that, when user is scrolling a `ListView` and suddently user finger leaves the screen (`PointerUpEvent`). There are some complex logic happening to handle the pointer up event inside `ListView`, so I do not want to reproduce it in preempt render. If so, the user pointer up event will not be handled until the janky frame ends, causing both lagging and jank (because there is no pointer move event after pointer up, so ListView no longer moves, so it looks janky).

In summary, when there is something that cannot be handled by preempt rendering, we will jank because preempt can do nothing about that. With brake, there is no such problem. Therefore, the preempt is the main workhorse, while the brake fixes some edge cases that preempt is not able to do.

For a figure demonstrating this, please refer to the next part.

## Formalize the problem

Again, figure first. The first row is the problem, the second row is the control group where there is no jank and no flutter_smooth, and the third row is the solution.

```mdx-code-block
import BrakeMain from '@site/static/svg/brake_main.svg'

<center><BrakeMain/></center>
```

In the first row (the problem), there is an event that cannot be handled at time 1.8. Then, even though all subsequent preempt renders happen, they are marked red and result in janks, because they cannot produce meaningful UI scene, since preempt render cannot handle that event. It is only after (roughly) time 4 when the event is handled, that the preempt render and normal render starts to produce meaningful data. Therefore, we do see several janks, even though it is 60FPS and preempt is running.

As for why 2 is "ok" instead of "jank" even though event (suppose it is pointer event) happens at 1.8, this is because of the gesture system delay. Looking at the second row, which is the control group when there is no UI jank and no flutter_smooth, we see the event effects are not displayed until time 4.0. Therefore, if we manage to deliver a scene with event effects at 4.0, we do not cause any jank, and have jank otherwise.

## The solution

Now comes the solution in the third row of the figure. 

When the event occurs, we realize it and triggers a brake. When doing so, the build and layout of the main tree will halt as fast as possible, by putting a placeholder widget instead of doing the real (and heavy) build or layout. Therefore, the main janky frame is quickly halted, and now there is a chance for ListView to handle the event, since its RenderObject is now non-dirty and we are in a normal between-frame event handling stage. After the event is handled (and other between-frame things are done), the next frame is started immediately. As long as it is started before 2.9 in the figure (i.e. have a few milliseconds before deadline), we can trigger a preempt render, so no jank will happen.

Remark: The empty space around 2.0-2.5 in the figure is because, there are some extra things to do by Flutter between two frames. However, it does not matter as long as such extra thing do not occupy about 16ms.

### Details

To correctly implement it, there are some other details as well:

* Skip potential preempt render in build/layout phase and PostDrawFrame phase. Otherwise, we will submit too many scenes to rasterizer.
* Immediately start next frame (in the figure example, it starts around 2.5), as if it should have started earlier (in the example, as if it should have started at 2), instead of starting it in the next vsync. Otherwise, as can be seen in the figure, if the next frame starts at 3 not 2.5, then there is no chance to submit a preempt render around 2.9, so we will jank one frame.

## Comparison

At a first glance, it looks a bit familiar with the "split heavy work into multi frames and early return in each frame" prior work. To fully understand this design, we need to notice their differences, mainly in the occasion when to trigger an early return:

In prior work, it is triggered unconditionally, after a portion of heavy work has been done (as long as we are discussing heavy-work frames). In brake, it is never triggered, unless preempt notices there are some events that it cannot handle within preempt render.

## Cost analysis

Firstly, the amortized cost is very small. With the comparison above, we now clearly see why ths cost is minor, even though the prior work has many shortcomings. It is mainly because the frequency of triggering the mechanism. In prior work, the early return mechanism with all the cost are triggered on each and every 16.67ms (again assuming we are discussing heavy-work frames). However, in the brake, it is triggerred very sparsely. For the ListView scrolling example, only the pointer down and pointer up (the latter can be overcome indeed) needs to trigger brake. Suppose a scroll takes 2 second, then only 1/60 of the  scenarios trigger brake, so the amortized cost is very tiny if not neglitable.

Secondly, consider the frame that has the worst cost, it is still no problem. If the brake is alone, we do face the risk of jank. For example, just like prior work, if we miss the deadline by even 0.01ms, then we will face one jank, and as discussed earlier, such probablity is inevitable. However, the brake is not alone, but accompanied with the preempt. Thus, it has much looser timing requirements - as long as we start a new frame *a few* milliseconds before the deadline, we are safe and no jank will happen. For a concrete example, in the third row of the figure, even if the second frame starts at (e.g.) time 2.8, there is still no jank.