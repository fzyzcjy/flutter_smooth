# Analysis

What problem will we have, given the original Flutter engine described above?

## Allow multi-render in one plain frame

It is a must to add that change (create a continuation if there is none) to `Render`. This is because, we call `Render` multiple times for one `BeginFrame`. The original code will reject all `Render`s except for the first one, thus the whole flutter_smooth will not work because we can no longer submit anything more to render.

## Fix unnecessary jank

Consider the following scenario. The first row is the case without code change to `animator.cc`, and the second row is the case with change.

```mdx-code-block
import RasterizerQueueJank from '@site/static/svg/rasterizer_queue_jank.svg'

<center><RasterizerQueueJank/></center>
```

TODO