# Post draw frame

There is indeed one flaw in the figure above. Consider the first row in the following figure (the second row is the solution, so please skip it first):

```mdx-code-block
import PreemptPostDrawFrame from '@site/static/svg/preempt_post_draw_frame.svg'

<center><PreemptPostDrawFrame/></center>
```

The result is one frame jank, because there is no rasterizer output in 3-4 vsync interval. Why does that happen? Try to scroll back and have a comparison with the original figure. Do you spot the problem? It is because, at (e.g.) time 1.9, we should trigger a preempt render. However, in this scenario, when that time comes, we are no longer in build/layout phase but in the (short) paint/composite/finalize phase. Therefore, no preempt render happens at all, and we submit one less scene to the rasterizer.

The solution is shown in the second row of the figure: Add one more preempt render (called `PostDrawFrame` preempt render in my code). More specifically, when the frame is about to finish, we check whether the scenario is like the case in the figure. If so, we call preempt render once more and submit one more scene.

Remark on timing: It is critical to provide the correct time stamp when build/layout/paint/..., because a wrong timestamp will make animations output the wrong scene. So what is the time stamp for this `PostDrawFrame` phase? Indeed, it is the time stamp as if a plain-old normal frame begins at "2" (the timestamp value indeed corresponds to the "3" time, but this 1-frame shift is a constant and another story and I should explain separately). By doing so, we see that, in each vsync interval, there is not only one rasterizer output, but the output also has animation timestamp increasing one by one. So we not only observe 60FPS, but also observe smooth animation instead of jumping animations.