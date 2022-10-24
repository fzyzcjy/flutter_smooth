# Target problems

What problems does this package aim to solve?

## Main: Jank by build and layout

The main problem that the package solves, surely, is the jank caused by build and layout phase. As we know, build and layout phase is usually the slow and heavy part in the UI thread. This is also experimentally verified in the [benchmark](../benchmark) chapter.

## Others

In addition, there are some other problems that this package seem to solve as well, and I list it as follows. I have not done solid experiments, so these are mainly theoretical analysis - feel free to PR your experiments if you are interested.

### Jank by garbage collection

This is mainly described in [the GC section](infra/gc/between-frame). To summarize, without this package, GC will cause a jank if it runs more than (16.67-N) milliseconds where N is the UI thread duration, which is very possible. On the other hand, with this package, even if GC needs to run for (for example) 14ms per 16.67ms, there will be no jank.

### Jank by memory locality

As [pointed out](https://discord.com/channels/608014603317936148/608021234516754444/1022296432738320454) by @gaaclarke, a possible source of slowness is memory locality problem, due to the nature of Dart and Flutter, which will be hard to fix. However, this package seems to fix it, because it solves whatever causes the build/layout slowness.

### Jank by other phases

Firstly, if the `finalize` phase executes too long, it seems quite easy to modify the current code a little bit to add preempt rendering into that phase, such that it never janks. This is because we already have a preempt at the end of it and that phase does not touch the layer tree.

Secondly, for jank by phases like `animation`, `compositing` and so on, it seems possible to inject preempt rendering as well. I have not checked into the details, because those phases are really fast and I never see a real-world case yet. But if you do, do not hesitate to create an issue.