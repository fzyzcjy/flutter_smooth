# Fix jank by await vsync

:::info

**Title**: Fix janks caused by await vsync in classical Flutter

**Link**: https://github.com/flutter/engine/pull/36911

:::

This fixes the jank happened in **classical** Flutter, even without the existence of flutter_smooth

During experiments, I observe a phenomenon: Even when the UI thread finishes everything *before* the deadline (vsync) a few milliseconds, the next frame is scheduled *one* vsync later, causing one jank. For example, UI thread may run from 0-15ms, but the next frame starts from 33.33ms instead of the correct 16.67ms.

An example screenshot can be seen at the end of this proposal. I added a timeline event, `Animator::AwaitVSync`, so we can clearly see when vsync await is called. (This screenshot has roughly 3ms space; but more frequently, I see this bug when there is about 0.5-2ms space.)

Therefore, this PR tries to fix this problem. The main idea is that, when detecting we are very near the next vsync, we do not wait at all, but instead directly start the next frame.

![image](https://user-images.githubusercontent.com/5236035/197105732-7c0bfbad-8816-46c0-85b1-5007d0f82d5d.png)

zoom in:

![image](https://user-images.githubusercontent.com/5236035/197105742-c511137c-3089-4ff9-b102-52bdfcfc72f9.png)

further zoom in:

![image](https://user-images.githubusercontent.com/5236035/197105754-fd471b8f-1ae7-45cb-b4d8-3163beb0d87a.png)