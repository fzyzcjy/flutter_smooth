# Multi-render

:::info Upstream PR

**Title:** Allow render to be called multiple times for one BeginFrame

**Link**: https://github.com/flutter/engine/pull/36438

:::

One result of the code change is that, it allows multi-render in one plain frame.

It is a must to add that change (create a continuation if there is none) to `Render`. This is because, we call `Render` multiple times for one `BeginFrame`. The original code will reject all `Render`s except for the first one, thus the whole flutter_smooth will not work because we can no longer submit anything more to render.