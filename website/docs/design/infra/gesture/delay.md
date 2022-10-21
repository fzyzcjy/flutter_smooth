# Deliberate delay

We need to deliberately delay about one frame for the pointer events, in order to achieve the same behavior as original Flutter.

Again figure first, and then explain:

```mdx-code-block
import GestureDelay from '@site/static/svg/gesture_delay.svg'

<center><GestureDelay/></center>
```

The first row is the scenario when there is no flutter_smooth and the UI thread is non-janky, used as a control group. As we can see, even though the event happens at time 1.8, it is only displayed to screen during 3-4 interval (indeed user will see it at time 4.0).

The second row is a janky frame with flutter_smooth. We could have directly process the pointer event at the preempt render near time 2.0. However, that will make flutter_smooth be inconsistent with the original Flutter. Therefore, we deliberately ignore that pointer event, and only handle it at the preempt render near time 3.0.

If latency is a concern, it may be possible to change the logic and remove this deliberate delay.