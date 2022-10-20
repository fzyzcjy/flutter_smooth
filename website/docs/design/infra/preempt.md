# Preempt

## Starting from plain

To begin with, suppose we have some jank frames caused by slow build/layout, and there is no optimization at all. Then the timeline looks like the following.

**Image caption**: Vertical line means vsync signal, UI and raster refers to the UI thread and rasterizer thread, respectively. Take the frame starting at "2" for example. The computation is heavy and takes about 2.5x16.67ms to finish, thus we observe jank in the vsync interval of "3-4" and "4-5" because we do not see any rasterizer output.

```mdx-code-block
import PreemptTimelinePlain from '@site/static/svg/preempt_timeline_plain.svg'

<center><PreemptTimelinePlain/></center>
```

## Prior work

In [literature review](../review/summary), we have seen many attempts to solve this jank problem. If we take a step back, those ideas are within the range of "split heavy work into multi frames and early return in each frame". The differences among those solutions are details inside it. For example, to decide when to trigger it, some decides to do it when near a timeout, while some does predetermined amount of work regardless of time. As for where to implement the logic, some hack the build phase and the widgets, while some modifies the layout phase and RenderObject.

Since they has the same high-level logic, we can draw them using one figure as follows:

**Image caption**: The one heavy frame that runs at 2-4.5 in the previous figure, now becomes three shorter frames that runs inside 2-6. The frame at about 2-2.7 demonstrates when early return happens too early, and the frame at about 3-4.1 is an example that the early return happens too late, which seems hard to avoid.

Please note that, many other shortcomings are not displayed in the figure, such as overhead. 

```mdx-code-block
import PreemptTimelineTheirs from '@site/static/svg/preempt_timeline_theirs.svg'

<center><PreemptTimelineTheirs/></center>
```

## My approach

My method solves the problem in another way: Keep heavy work still in one long frame, and call extra routine periodically. That may sound a bit abstract, so let's look at the following figure.

The extra green box below UI thread is the preempt rendering logic. Without digging into the details, the main idea is that, we add those extra green boxes (preempt rendering) which emits (i.e. calls `window.render`) layer tree to the rasterizer, so we do see new content displayed to screen in each 16.67ms.

```mdx-code-block
import PreemptTimelineSmooth from '@site/static/svg/preempt_timeline_smooth.svg'

<center><PreemptTimelineSmooth/></center>
```

In the next sections, I will explain more details.
