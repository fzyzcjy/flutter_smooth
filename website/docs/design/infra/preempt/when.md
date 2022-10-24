# When to trigger

The answer is, when inside the build or layout phase, just call it when `now - lastVsyncTime > threshold` where threshold is smaller than and near 16.67ms. In other words, trigger when we are near a deadline. Using pseudo-code, it is:

```dart
bool shouldTriggerPreempt() => now - lastVsyncTime > roughly_2ms;
```

## What happens if triggered too late/early

Indeed, this approach is robust to the choice of threshold, as well as the execution time of preemptRender itself. If the preemptRender misses the vsync deadline, nothing bad will happen. This is shown in the figure below.

For completeness, three cases are discussed - suppose a janky frame needs <16ms, ~32ms, and infinitely long, respectively. In the diagram, we deliberately assume the `preemptRender` *all* misses the vsync deadline. Surely, if they meet the deadline, the scenario can just be better instead of worse. As can be seen in the diagram, in each 1/60s, we see the rasterizer thread produce one outcome, so it runs exactly at 60fps smooth without jank or other uncomfortable feelings.

```mdx-code-block
import PreemptDifferentJank from '@site/static/svg/preempt_different_jank.svg'

<center><PreemptDifferentJank/></center>
```

## What about other phases

We do not need to consider the paint or compositing phase, because that is usually very fast.

We can consider and trigger preempt in the finalize phase indeed, but since I have not seen cases when it is super slow, I have not done that. If you need that, just trivially mimic the preempt triggerring in `PostDrawFrame`(discussed below).

In [post-draw](post-draw) section, we will see there is one extra case when it needs to be triggered to fulfill the theory.