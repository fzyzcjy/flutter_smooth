# Comparison

:::info

Because of @JonahWilliams's suggestion, I wrote this section in the design doc and copy it here.

It mainly compares the "preemption" idea of this package with other methods, and does not discuss other parts of this package such as brake or modification to rasterizer.

:::

There are some other methods (abbreviated as “OM” in below) related to smoothness optimizations, which can be roughly separated into two categories:

1. Modify the build phase, including the following (abbreviation: OM-B)
   1. The `keframe` package
   2. My (failed) [experiments](https://github.com/flutter/flutter/issues/101227#issuecomment-1250186784) (abbreviation: OM-B-M)
2. Modify the layout phase, including the following (abbreviation: OM-L)
   1. Googlers (@Hixie, @dnfield and other googlers) had some discussions about it
   2. Several bytedance infra team people also had some discussions
   3. My (failed) [experiments](https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781) (abbreviation: OM-L-M)

Indeed, I have made many failed experiments and failed proposals before reaching this design you are reading :)

In the following subsections, problems of those approaches will be discussed. Those problems are overcome in the proposed method.

## Unnecessary re-layout

OM-B and OM-L methods have the extra cost of re-layouting subtrees in each frame.

For a simple example, suppose we have a Column/ListView with five children. In frame #1, it renders the first, and children 2-5 return empty boxes. In frame #2, the Column has to perform a full layout (i.e. call `performLayout()` fully), so is frame #3, #4 and #5. Different OM-B and OM-L methods may vary about how many widgets are rendered in each frame, but the relayout overhead is still there.

If it were just a Column we may accept the overhead, but it can be a big ancestor tree. We have to re-layout over and over again in every frame, for the whole ancestor tree, up to the nearest relayout boundary. The consequences of such overhead will be discussed further below. The proposed method does not have the problem.

## Unnecessary re-paint

OM-B and OM-L methods have the extra cost of unnecessary re-paint in each frame.

Suppose a heavy rendering needs 0.1s, then OM-B and OM-L methods will run the full paint phase for 6 times, while the proposed method only needs one paint call. This is especially troublesome when painting is slow, and still not very great even if each paint only takes 2ms - it adds up and occupies precious time of useful work. The proposed method does not have the problem.

## Unnecessary whole-pipeline re-execution

OM-B and OM-L methods need to re-execute the whole pipeline while the proposed method does not.

For example, when Keframe replaces placeholders with real widgets, or when other OM-B and OM-L methods run build/layout on a few widgets, it is driven by the vsync signal to execute the drawFrame and submit to the engine, so it will execute the complete build/layout/paint etc process. However, the build/layout/paint other than the actual widget is not necessary.

On the contrary, in the proposed method, the UI thread just voluntarily submits a frame to the Engine after roughly 16ms of detection, and then returns to the normal rendering flow without much additional overhead.

<small>(Suggested by @Nayuta)</small>

## Unnecessary CPU idle even when pending work

OM-B and OM-L methods will make CPU idle, even though there is a ton of work to be done, thus making more unnecessary perceptual lagging. The idle period for UI thread is after current pipeline ending and before next vsync.

Moreover, it is hard to remove such idle periods. If we halt too early (say, current frame ends at 12ms), then we waste 16.67-12=4.67ms; if we halt too lately (say, current frame ends at 19ms), then we even waste more - 16.67x2-19=14.3ms, because we are idle until the next vsync. As is discussed in other subsections, it is hard to know when to halt the existing build/layout can make the current frame end at 16ms.

In my OM-L-M experiment (can see a timeline figure there), about 39% of the UI thread time is idle, though there is still build/layout work to do. This may be tunable to be less harmful with careful choice of parameters, but by nature it cannot be fully removed.

On the contrary, the proposed method has exactly 0% idle time while work is not finished, without any need of tuning parameters.

## Unnecessary FPS drop: 30FPS when could be 59FPS

OM-B and OM-L methods will immediately drop to 30FPS even if the frame is only 0.01ms longer than 16.67ms, while the proposed method will be 59FPS.

The “a little bit longer than 16.67ms” situation is inevitable because of two reasons: On one hand, as described above, when we decide to suspend/halt, we still have an unpredictable non-negligible amount of work remaining to do within the current frame. On the other hand, there may not be enough positions to halt, such as when a single widget layout can take several milliseconds. Thus, we will either halt too early (cause problems pointed out above) or too late (the drop-to-30FPS problem).

The analysis of 30FPS is as follows. To simplify math, suppose each frame needs 16.67+0.01ms and continue for one second. Then, those approaches will miss half of the vsync, i.e. will only get vsync per 33.33ms. Therefore, they will simply run the pipeline per 33.33ms, which is 30FPS. On the contrary, the proposed method will call `window.render` to submit a frame to the rasterizer per 16.67+0.01ms, regardless whether it misses a vsync or not, so we will see roughly 59 frames on the screen in one second.

Remark: The “average FPS” in DevTools [seems to be wrong](https://github.com/flutter/devtools/issues/4522) for such cases.

Remark: Given this discussion, when reading something like “17ms” in the “*_frame_build_time_millis” in benchmark results, it indeed means a completely different end-user feeling (30FPS vs 59FPS). In the “When to call preemptRender” section later, there are also some discussions.

## Unnecessary perceptual slowness

OM-B and OM-L methods take more frames to render all elements in the whole UI than it could have been.

This is a direct consequence of the problems above, since the system has less time to deal with the real heavy subtree needing build/layout.

In my OM-L-M (rough and failed) experiment, each frame takes 22ms to compute (indeed occupying 33.33ms slot), while there are only about 13.5ms for the interested computation. Even if we only want 30FPS (definitely not want), the minimal overhead is still 8.5ms per 33.33ms = 26%. If we want 60FPS, then it seems that only 6.5ms out of 16.67ms will be for the interesting computation - 61% time is wasted and only a third of time is doing the meaningful job. For a more complicated application, the overhead may be even larger, making the total overhead bigger. On the contrary, the proposed method has much less overhead (0.53ms per frame, to be discussed in the experiment section).

As an extreme, for complex applications, the overhead above plus even minimalist interesting computation will exceed 16.67ms. Then it is impossible to get 60FPS using OM-B/OM-L, while the proposed method can still easily achieve that.

## Costly suspending

This point is related to some points above, using another perspective to view it. In some of the OM-B and OM-L methods, the layout phase will be suspended via various approaches, such as early-returning the layout function (OM-L-M), build a placeholder widget (OM-B), etc. However, it seems that all has overhead in terms of memory and CPU. On the contrary, the proposed approach does not have overhead when suspending.

## Coarse suspending points

OM-B and OM-L methods can only act per Widget/RenderObject, so if one Widget/RO is too slow to build/layout, it still janks. A real case may be a text widget containing long content.

As @dnfield points out in [the comment](https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit?disco=AAAAgdW1Swc): “Layout for a single widget can easily blow through the frame budget. That's part of what we'd like to solve with an interruptible approach, assuming such an approach is possible.”

On the contrary, the proposed method can pause in the middle of any arbitrary function, as long as the function is called during the build/layout phase. This is because the `maybePreemptRender` call can be inserted anywhere you like.

## Problems specific to a subset of methods

The following drawbacks mainly apply to a subset of the OM methods.

* Some of the OM-B methods add exactly one widget in one frame, no matter how fast or slow it is. As we know, the build/layout time for one widget varies greatly on different devices. For example, on low-end devices it may still be too much to add one widget in one frame, then we still get jank. On high-end devices, it may be OK to add five widgets in one frame, then we are rendering the UI using 5 frames even if we could have done it within 1 frame. What’s more, since we want to support slow, slower, and slower-than-slower devices, it means our widget must be very tiny if we really want 60FPS on them, but then on high-end devices the perceptual latency will be quite large. The proposed method does not have the problem, and is self-adaptive. @nayuta, the author of `keframe`, also [recognized](https://github.com/LianjiaTech/keframe/issues/12#issuecomment-1238873216) the problem.
* Some of the OM-B methods always have one frame lag. For example, if you provide a child in frame #10, it will never be visible until frame #11 ends, no longer how high-end and how spare the device is. In addition, as @DanField points out, “this will cause problems with scrolling/touch events”. The proposed method does not have the problem.
* For those “build/layout as many as possible, until it is near timeout” OM-B methods, like in OM-B-M, there are also problems: When we see it is nearly timeout and do not provide further build/layout, we will still have to do a lot. We have to finish the build/layout of the remaining non-managed widgets, and we have to paint the whole tree, finalize (dispose widgets) the whole tree, etc. All of them take UI thread time, and takes a lot in scroll-ListView case in my experiment. Then, even if we halt at, say, 12ms, we may still miss the 16.6ms deadline, and it is not 60fps now. On the contrary, the proposed method will not have so much overhead, but only do a little job (send existing layer tree to raster thread), which is much more predictable in terms of time, so we have less risk of missing 16.6ms.
* In some of the OM-L methods, users of Flutter framework may need to modify their code because implicit assumptions such as “build/didUpdateWidget happens on each frame” has been broken. More details: When suspended, those approaches will have some subtree of RenderObject whose performLayout has not been called in this frame, i.e. still dirty, even if a frame ends. Given the existence of LayoutBuilder, we will also have some Widget.build not called within that frame. This requires each and every widgets and RenderObjects to update their code to allow such behavior, which will not only be a lot of work inside Flutter framework widgets, but also a lot for all package and app developers. The proposed method does not have the problem.
* In OM-L-M, those approaches paint nothing (i.e. do not call child.paint) if a Suspendable is suspended. This will destroy the layer tree and C++ engine layer trees, making performance much worse. This may be overcomed but I have not experimented. The proposed method does not have the problem.
* In OM-L-M, if a child under Suspendable marks itself as needed to relayout/rebuild, and there is a relayout boundary between that child and Suspendable, then the suspending mechanism will not work at all. The proposed method does not have the problem.