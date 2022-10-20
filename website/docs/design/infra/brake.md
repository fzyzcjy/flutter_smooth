# Brake

## Why

Why do we need another mechanism, given that the Preempt already works well? Consider the following scenario: The user taps the screen (`PointerDownEvent`) in the middle of a long janky frame. More concretely, for example, when ListView is shifting quickly by inertia and during a long janky frame, the user drags the screen wanting to further scroll. As will be discussed in the [gesture](gesture) section, it is impossible to handle `PointerDownEvent` in the *middle* of a long janky frame. Therefore, if we only have the Preempt mechanism, we cannot respond to the user interaction until the janky frame ends.

Another example is that, when user is scrolling a `ListView` and suddently user finger leaves the screen (`PointerUpEvent`). There are some complex logic happening to handle the pointer up event inside `ListView`, so I do not want to reproduce it in preempt render. If so, the user pointer up event will not be handled until the janky frame ends, causing both lagging and jank (because there is no pointer move event after pointer up, so ListView no longer moves, so it looks janky).

For a figure demonstrating this, please refer to the next part.

## How

Again, figure first:

TODO