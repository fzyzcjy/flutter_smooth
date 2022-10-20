# Brake

## Why

Why do we need another mechanism, given that the Preempt already works well? Consider the following scenario: The user taps the screen (`PointerDownEvent`) in the middle of a long janky frame. More concretely, for example, when ListView is shifting quickly by inertia and during a long janky frame, the user drags the screen wanting to further scroll. As will be discussed in the [gesture](gesture) section, it is impossible to handle `PointerDownEvent` in the *middle* of a long janky frame. Therefore, if we only have the Preempt mechanism, we cannot respond to the user interaction until the janky frame ends.

Another example is that, when user is scrolling a `ListView` and suddently user finger leaves the screen (`PointerUpEvent`). There are some complex logic happening to handle the pointer up event inside `ListView`, so I do not want to reproduce it in preempt render. If so, the user pointer up event will not be handled until the janky frame ends, causing both lagging and jank (because there is no pointer move event after pointer up, so ListView no longer moves, so it looks janky).

In summary, when there is something that cannot be handled by preempt rendering, 

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

Remark: The empty space around 2.0-2.5 is there, because there are some extra things to do by Flutter between two frames. However, it does not matter as long as such extra thing do not occupy about 16ms.

When the event occurs, we realize it and triggers a brake. When doing so, the build and layout of the main tree will halt as fast as possible, by putting a placeholder widget instead of doing the real (and heavy) build or layout. Therefore, the main janky frame is quickly halted, and now there is a chance for ListView to handle the event, since its RenderObject is now non-dirty and we are in a normal between-frame event handling stage. After the event is handled (and other between-frame things are done), the next frame is started immediately. As long as it is started before 2.9 in the figure (i.e. have a few milliseconds before deadline), we can trigger a preempt render, so no jank will happen.

### Details

To correctly implement it, there are some other details as well:

* Skip potential preempt render in build/layout phase and PostDrawFrame phase. Otherwise, we will submit too many scenes to rasterizer.
* Immediately start next frame (in the figure example, it starts around 2.5), as if it should have started earlier (in the example, as if it should have started at 2), instead of starting it in the next vsync. Otherwise, as can be seen in the figure, if the next frame starts at 3 not 2.5, then there is no chance to submit a preempt render around 2.9, so we will jank one frame.

## Comparison

TODO

TODO also explain cost is minor (#6180)

TODO also explain, since preempt, it is ok to be slow for between-frame