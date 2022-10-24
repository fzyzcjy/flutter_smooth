# Introduction

## Why

Why do we need another mechanism, given that the Preempt already works well? Consider the following scenario: The user taps the screen (`PointerDownEvent`) in the middle of a long janky frame. More concretely, for example, when ListView is shifting quickly by inertia and during a long janky frame, the user drags the screen wanting to further scroll. As will be discussed in the [gesture](../gesture/impl) section, it is impossible to handle `PointerDownEvent` in the *middle* of a long janky frame. Therefore, if we only have the Preempt mechanism, we cannot respond to the user interaction until the janky frame ends.

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