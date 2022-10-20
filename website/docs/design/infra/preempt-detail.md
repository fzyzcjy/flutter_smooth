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

The answer is, when inside the build or layout phase, just call it when `now - lastVsyncTime > threshold` where threshold is smaller than and near 16.67ms. In other words, trigger when we are near a deadline.

We do not need to consider the paint or compositing phase, because that is usually very fast.

We can consider and trigger preempt in the finalize phase indeed, but since I have not seen cases when it is super slow, I have not done that. If you need that, just trivially mimic the preempt triggerring in `PostDrawFrame`(discussed below).

### What happens if triggered too late/early

Indeed, this approach is robust to the choice of threshold, and the execution time of preemptRender itself. If the preemptRender misses the vsync deadline, nothing bad will happen. This is shown in the figure below.

For completeness, three cases are discussed - a janky frame needs <16ms, ~32ms, and infinitely long. In the diagram, we deliberately assume the `preemptRender` *all* misses the vsync deadline. Surely, if they meet the deadline, the scenario can just be better instead of worse. As can be seen in the diagram, in each 1/60s, we see the rasterizer thread produce one outcome, so it runs exactly at 60fps.

```mdx-code-block
import PreemptDifferentJank from '@site/static/svg/preempt_different_jank.svg'

<center><PreemptDifferentJank/></center>
```

## What to do during preempt

Abstractly speaking, we should produce a new UI when doing a preempt. For example, when showing enter-page animation, the new UI will be a screen shifting pixel by pixel as time goes by.

More concretely, what is the new UI? This needs some background of Flutter internal implementation. The UI that the ui thread submits to rasterizer thread is indeed a `Scene` object, and it is submitted to rasterizer via `window.render`.

## How to create `Scene`

So how can we create the latest UI inside the preempt render? Let's firstly discuss the lowest-level approach, and below we will provide a wrapper so users can create widgets easily.

Recall how Flutter is implemented. During a normal frame pipeline, the build and layout phase modifies `RenderObject` (and other things), while the `Layer` tree is untouched and is still old (i.e. has content from last frame). During the paint phase, `RenderObject` will modify the `Layer` tree by utilizing its new data. Finally, the `Scene` is built from the `Layer` tree, and submitted to rasterizer via `window.render`.

Recall the preempt render is called *inside* the build or layout phase. Therefore, during a preempt render, we have dirty `RenderObject` tree and should not utilize it. However, the `Layer` tree is, foruntately, non-dirty and ready to be used, with content generated from the plain-old rendering in the last frame.

Now consider what happens during a preempt render. For simplicity, suppose we are doing a page-enter animation, and the widget handling page shifting is bound to a specific `OffsetLayer`. Then, inside preempt render, we simply do something like `thatOffsetLayer.offset += 10px`. By doing so, the UI will have the new page shifted a bit, i.e. the animation progresses a bit. After that, we can submit the whole layer tree object to rasterizer (indeed convert to `Scene` and call `window.render`).

Thus, we now have a mechanism for 60FPS smooth animation, no matter how heavy the tree is to build/layout.

## The `PreemptBuilder` API

If this package stops at the API above, nobody will use it - you will have to write a ton of code to modify the `Layer` tree by yourself. The goal in this part is to create a developer-friendly API, indeed the `PreemptBuilder`. Recall the definition of `PreemptBuilder(builder: ..., child: ...)` - put the things that you want to be smooth inside the builder, and we are done. How is that implemented?

The core idea is to use an auxiliary tree in addition to the main tree. In other words, we create a separate `BuildOwner`, `PipelineOwner`, root widget, etc. Then, we are free to call its `buildScope`, `flushLayout`, `flushPaint`, etc, at *any time* at any frequency we like. Its input is a widget tree (indeed `PreemptBuilder.builder` output), and its output is a `Layer` tree (indeed to be inserted to the main tree).

Then, we need to graft the auxiliary-tree’s layer tree and the main-tree’s layer tree. Shortly speaking, we do so in `paint` function by `context.addLayer` and so on. Details can be found in the code.

## The `PostDrawFrame` phase

There is indeed one flaw in the figure above. Consider the first row in the following figure (the second row is the solution, so please skip it first):

```mdx-code-block
import PreemptPostDrawFrame from '@site/static/svg/preempt_post_draw_frame.svg'

<center><PreemptPostDrawFrame/></center>
```

The result is one frame jank, because there is no rasterizer output in 3-4 vsync interval. Why does that happen? Try to scroll back and have a comparison with the original figure. Do you spot the problem? It is because, at (e.g.) time 1.9, we should trigger a preempt render. However, in this scenario, when that time comes, we are no longer in build/layout phase but in the (short) paint/composite/finalize phase. Therefore, no preempt render happens at all, and we submit one less scene to the rasterizer.

The solution is shown in the second row of the figure: Add one more preempt render (called `PostDrawFrame` preempt render in my code). More specifically, when the frame is about to finish, we check whether the scenario is like the case in the figure. If so, we call preempt render once more and submit one more scene.

Remark on timing: It is critical to provide the correct time stamp when build/layout/paint/..., because a wrong timestamp will make animations output the wrong scene. So what is the time stamp for this `PostDrawFrame` phase? Indeed, it is the time stamp as if a plain-old normal frame begins at "2" (the timestamp value indeed corresponds to the "3" time, but this 1-frame shift is a constant and another story and I should explain separately). By doing so, we see that, in each vsync interval, there is not only one rasterizer output, but the output also has animation timestamp increasing one by one. So we not only observe 60FPS, but also observe smooth animation instead of jumping animations.

