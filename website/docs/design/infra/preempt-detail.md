# Preempt details

Given the main idea in last section, now let's dig into the details. It may look a big challenging to grasp everything at first glance, but just focus on the main figure and we are just adding details onto it.

<small>(Repeat the main figure as follows for your convenience)</small>

```mdx-code-block
import PreemptTimelineSmooth from '@site/static/svg/preempt_timeline_smooth.svg'

<center><PreemptTimelineSmooth/></center>
```

## How to trigger preempt

By normal function call. The psuedo simplified core code looks like:

```dart
// you know, the workhorse in layout phase
void performLayout() {
  if (shouldTriggerPreempt) preemptRender();
  ...original code...
}
```

As for implementation details, I create `PreemptPoint` widgets which does this check at build and layout time. An alternative solution, if Flutter merges my PR, is to inject this if-clause into `RenderObject.performLayout`.

If you are familiar with the prior approaches (discussed in literature review), this may need a bit of time to grasp. In prior approaches, *early return* is utilized (i.e. `if (nearDeadline) return; else doHeavyJob();`), and the main thread finally has zero call stack depth. However, to the contrary, this approach only *calls* a normal function.

## When to trigger preempt

First question: when should we trigger a preempt, i.e. put a little green box? The answer is, just call it when `now - lastVsyncTime > threshold` where threshold is smaller than and near 16.67ms. In other words, trigger when we are near a deadline.

### What happens if triggered too late/early

Indeed, this approach is robust to the choice of threshold, and the execution time of preemptRender itself. If the preemptRender misses the vsync deadline, nothing bad will happen. This is shown in the figure below.

For completeness, three cases are discussed - a janky frame needs <16ms, ~32ms, and infinitely long. In the diagram, we deliberately assume the `preemptRender` *all* misses the vsync deadline. Surely, if they meet the deadline, the scenario can just be better instead of worse. As can be seen in the diagram, in each 1/60s, we see the rasterizer thread produce one outcome, so it runs exactly at 60fps.

TODO figure

## How to present new UI during preempt

TODO explain we have old layer tree

TODO "From preemptModifyLayerTree to PreemptBuilder" in design doc

### Starting simple: Modify manually

TODO

### Wrap it: `PreemptBuilder`

TODO

## The `PostDrawFrame` phase

TODO explain the scenario

TODO

