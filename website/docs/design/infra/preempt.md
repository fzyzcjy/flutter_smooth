# Preempt

In [literature review](../review/summary), we have seen many attempts to solve this jank problem. If we take a step back, those ideas are within the range of "split heavy work into multi frames and early return in each frame". The differences among those solutions are details inside it. For example, to decide when to trigger it, some decides to do it when near a timeout, while some does predetermined amount of work regardless of time. As for where to implement the logic, some hack the build phase and the widgets, while some modifies the layout phase and RenderObject.

My method solves the problem in another way: Keep heavy work still in one frame and call extra routine periodically. That may sound a bit abstract, so let's look at the figure:

TODO figure

