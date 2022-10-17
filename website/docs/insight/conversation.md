---
title: Discussion
---

<!-- THIS IS AUTO GENERATED, DO NOT MODIFY BY HAND -->

:::info

This page contains a (sorted) copy of discussions happened on various places. The original sources are:

* TODO

:::

import DiscussionComment from '@site/src/components/DiscussionComment';

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-02T05:45:54Z" retrieveTime="2022-10-15T21:31:00.632251">

### [Proposal]Let Flutter run animations at 60fps even if there are heavy widgets, possibly using React Fiber-like or suspend-like algorithm?

EDIT: Design proposal https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit?usp=sharing

---

Below (folded) are the initial proposal. However, I have realized the initial proposal has many drawbacks, and have raised new proposals. For example, [the dual isolate](https://github.com/flutter/flutter/issues/101227#issuecomment-1249005541) (click to view that comment).

<details>

Hi thanks for the framework! As we all know, React Fiber improves the performance and smoothness of React. Currently I am also observing some jank for Flutter app even after optimizing it using the tooltips in official doc, and I do hope there can be something similar to Fiber in Flutter side.

p.s. Some doc about react fiber: https://github.com/acdlite/react-fiber-architecture

I am interested in making contribution when having time as well.

</details>

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-02T08:22:05Z" retrieveTime="2022-10-15T21:31:00.632251">

> if I understand correctly you compare reconciling DOMs to rebuilding the elements in a widget tree
and you are proposing to rebuild only certain elements the same way react-fiber prioritize

Possibly not only Widget build, but also layout, paint, etc. Since it is often the case that the layout/paint cost time.

> give the developer the ability to set a widgets to low rendering priority

Sounds reasonable.

</DiscussionComment>

<DiscussionComment author="maheshmnj" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-04T07:48:34Z" retrieveTime="2022-10-15T21:31:00.632251">

Hi @fzyzcjy, Thanks for filing the issue. I am quite not sure about the algorithm and its effectiveness. Labeling this issue for further insights from the team.

cc: @dnfield  

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-04T08:07:41Z" retrieveTime="2022-10-15T21:31:00.632251">

@maheshmnj Hi thanks for the reply.

I have made an attempt about doing async rendering *without modifying* Flutter framework: https://github.com/fzyzcjy/flutter_smooth_render But the result is not very interesting - seems that we really need to dig into the framework itself instead of making a wrapper layer around it.

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-04T14:56:51Z" retrieveTime="2022-10-15T21:31:00.632251">

I've been talking about something somewhat like this on the #hackers-framework channel in the past, but it's not a trivial problem to solve. I'd be interested in seeing more details about your designproposal and/or discussing on discord.

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-04T16:37:22Z" retrieveTime="2022-10-15T21:31:00.632251">

And FWIW, this is likely a pretty significant amount of work to do, but there are some people who have already started looking at parts of it @hixie @goderbauer 

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-04-05T00:31:09Z" retrieveTime="2022-10-15T21:31:00.632251">

@dnfield Hi thanks for the reply! 

> but there are some people who have already started looking at parts of it @Hixie @goderbauer

To avoid reinventing the wheel, I hope to listen to the parts before thinking about what to do next

</DiscussionComment>

<DiscussionComment author="wangying3426" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-08T02:57:10Z" retrieveTime="2022-10-15T21:31:00.632251">

@fzyzcjy Any update please? We are also interested in this feature.



</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-08T03:06:09Z" retrieveTime="2022-10-15T21:31:00.632251">

@wangying3426 Well, no updates from me since I want to firstly listen to the "who have already started looking at parts of it @Hixie @goderbauer"

</DiscussionComment>

<DiscussionComment author="JsouLiang" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-14T07:04:33Z" retrieveTime="2022-10-15T21:31:00.632251">

@Hixie @goderbauer @dnfield How do you think about this fiber proposal?

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-14T16:21:36Z" retrieveTime="2022-10-15T21:31:00.632251">

No one has come up with a workable proposal at this point in time. I think it's worth doing but it's not my top priority at the moment.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-14T23:11:50Z" retrieveTime="2022-10-15T21:31:00.632251">

> but it's not my top priority at the moment.

As mentioned earlier, I am willing to PR and contribute. But surely need some suggestions and discussions prior to start implementing :)

Btw I am not thinking about strictly implementing Fiber, since web model is not the same as Flutter model, but something inspired by it that can make our animations smoother.

</DiscussionComment>

<DiscussionComment author="JsouLiang" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T02:56:03Z" retrieveTime="2022-10-15T21:31:00.632251">

> > but it's not my top priority at the moment.
> 
> 
> 
> As mentioned earlier, I am willing to PR and contribute. But surely need some suggestions and discussions prior to start implementing :)
> 
> 
> 
> Btw I am not thinking about strictly implementing Fiber, since web model is not the same as Flutter model, but something inspired by it that can make our animations smoother.

I think so. Maybe we can create a document and then a detailed description
- the fiber node archive and it can be interrupted by reconciler
- how does the Fiber reconciler work
- how does the flutter framework need to do and how to design

How do you think about it? @fzyzcjy 

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:01:06Z" retrieveTime="2022-10-15T21:31:00.632251">

> @JsouLiang Maybe we can create a document and then a detailed description

Sure! Maybe we can firstly discuss about it (maybe just here? - just like how I have seen many Dart/Flutter design discussions happen) and a detailed doc after we draw a (draft) conclusion

> how does the flutter framework need to do and how to design

Btw, fiber can make animations smoother, but if I understand correctly, the smoothness is because that specific animation is driven by css, not js. This is contrary to flutter. For example, a CircularProgressIndicator, or even a scrolling of ListView, is driven by Dart code. Thus, we cannot easily say "let's give control to flutter engine / android / ios / whatever once in a while when we are doing build/layout/paint/whatever". If we simply do so, we will not get a smooth animation automatically. Instead, we may need to find out a more sophisticated approach.

</DiscussionComment>

<DiscussionComment author="JsouLiang" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:27:32Z" retrieveTime="2022-10-15T21:31:00.632251">

> but if I understand correctly, the smoothness is because that specific animation is driven by css, not js.

Yes, the CSS animation is driven by css, not through js
That mean, the CSS associated with the HTML element can calculate the animation difference directly, without going through JS. @fzyzcjy 



</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:28:45Z" retrieveTime="2022-10-15T21:31:00.632251">

Yes, that is why fiber is so useful. Indeed it is like, the web ui is driven by two things - the JS and CSS. Fiber pause JS once in a while so CSS things can come in and animate.

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:28:53Z" retrieveTime="2022-10-15T21:31:00.632251">

> @fzyzcjy Btw, fiber can make animations smoother, but if I understand correctly, the smoothness is because that specific animation is driven by css, not js. This is contrary to flutter. For example, a CircularProgressIndicator, or even a scrolling of ListView, is driven by Dart code. Thus, we cannot easily say "let's give control to flutter engine / android / ios / whatever once in a while when we are doing build/layout/paint/whatever". If we simply do so, we will not get a smooth animation automatically. Instead, we may need to find out a more sophisticated approach.

As you say, Web animation like css animate, Android ViewPropertyAnimator (maybe iOS also has similar animate mechanism), they all are driven by browser/system, but in Flutter it is driven by ourselves with all other business logic.

for more, Android's window transition animation is driven by WindowService seperately

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:38:50Z" retrieveTime="2022-10-15T21:31:00.632251">

@JsouLiang @xanahopper 

So, it is possible we come up with something slightly different?

For example, if we want to make some animations faster, like CircularProgressIndicator and ListView-scrolling, is it possible to do the following: We give CircularProgressIndicator high priority, and it must be layout/paint at 60fps. In the meanwhile, all other widgets will run one layout/paint across multiple frames with suspending just like what Fiber does. In other words, when vsync comes, CircularProgressIndicator will do all the layout/paint job, while other widgets will continue working on its layout/paint but will pause once it is near 16ms. Then, we can see CircularProgressIndicator smooth at 60fps, while other widgets having similar rendering speed as before.

Btw, some side remarks that is less like Fiber: Here is a tool that defers Widgets from being built https://github.com/LianjiaTech/keframe. But I guess we can make it more fine-grained and with more improvements since we are going to modify the flutter framework itself. For example, (very rough draft idea), can we modify the layout phase (or paint, or others), such that it pauses layouting the remainder (and will do it in the next frame), and let painting and other phases go first?

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:44:07Z" retrieveTime="2022-10-15T21:31:00.632251">

The hard part of all of this is to figure out how to do it without breaking existing Framework code.

I think it's probably possible, but it's not easy.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:44:58Z" retrieveTime="2022-10-15T21:31:00.632251">

> @dnfield without breaking existing Framework code

We are allowed to modify anything in Flutter, don't we :) Just not allowed to break existing API that is used by flutter users.

Then, maybe we can have a feature flag?

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:45:53Z" retrieveTime="2022-10-15T21:31:00.632251">

@fzyzcjy Yes, we all farmilar with KeFrame and has already applied some optimize like it.
> I guess we can make it more fine-grained and with more improvements since we are going to modify the flutter framework itself.

I think this may the point we are going to discuss.


> The hard part of all of this is to figure out how to do it without breaking existing Framework code.
> 
> I think it's probably possible, but it's not easy.
@dnfield we cannot just stop because is not easy. if it is a right way to improve it.


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:46:35Z" retrieveTime="2022-10-15T21:31:00.632251">

> we cannot just stop because is not easy. if it is a right way to improve it.

Same here :) I like challenging, i.e. exciting, work!

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:50:41Z" retrieveTime="2022-10-15T21:31:00.632251">

@fzyzcjy I'm interested in this topic and have been trying to go in a direction where Keframe can make the best use of each 16.7ms, since now each item will take the full 16.7ms (even though it may only take 1ms on some good devices). I'm trying to count the time taken by individual items to determine how many items should be rendered in the next frame.


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:52:19Z" retrieveTime="2022-10-15T21:31:00.632251">

Continue from the animation proposal above, with @dnfield's "without breaking existing Framework code":

Maybe we can have a global flag, say, `bool enableFiber = false`. By default it is false, so users can use existing API freely without any change. When user manually set it to true, our new feature runs.

The API may be as simple as a Widget, say, `HighPrioritySubTree(builder: (context, child) => build_your_subtree_here, child: put_static_child_here)`, just like animation builder widgets. That builder should wrap the CircularProgressIndicator in the example above. We may also add a `CancelHighPrioritySubTree` if needed. For example, when scrolling ListView, we may want the scrolling animation be at 60fps, while we have to accept that a big widget in ListView is slow to build. Then, we may wrap ListView with HighPrioritySubTree, and each child of ListView with CancelHighPrioritySubTree. By doing so, our ListView will be forcefully built at each frame, while its contents will be stale for a few frames.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T03:54:47Z" retrieveTime="2022-10-15T21:31:00.632251">

@Nayuta403 I have had similar thoughts before. The problem is, `build` phase is not the most costly one. There are `layout` and `paint` phase, etc, as well. What's worse, Flutter has C++ engine code which rasterizes and flush to the screen. That one can take a long time in some cases (for example, in my own app, when there is a ton of bezier curves). A widget may, for example, have very short `build` phase time but very long C++ rasterize time.

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T04:00:38Z" retrieveTime="2022-10-15T21:31:00.632251">

> The API may be as simple as a Widget, say, `HighPrioritySubTree(builder: (context, child) => build_your_subtree_here, child: put_static_child_here)`, just like animation builder widgets. That builder should wrap the CircularProgressIndicator in the example above. We may also add a `CancelHighPrioritySubTree` if needed. For example, when scrolling ListView, we may want the scrolling animation be at 60fps, while we have to accept that a big widget in ListView is slow to build. Then, we may wrap ListView with HighPrioritySubTree, and each child of ListView with CancelHighPrioritySubTree. By doing so, our ListView will be forcefully built at each frame, while its contents will be stale for a few frames.

@fzyzcjy I agree with switch flag, but some individual widget may still look verbose. I'd rather like to add a optional parameter to base class `Widget` to specify it's build/layout/render priority.
Than change default page transition widget, scrollable container to high priority and wrap its content to low priority.


</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T04:06:56Z" retrieveTime="2022-10-15T21:31:00.632251">

And here is another case may need to be consider: the list.
 in general container such as page, content size has no effect with container and other siblings, but things are different in list.
if we have different size of different item, we cannot just show placeholder with same size, scrolling when and after content item is building/layouting may cause a sudden change in list.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T04:09:32Z" retrieveTime="2022-10-15T21:31:00.632251">

>  I'd rather like to add a optional parameter to base class Widget to specify it's build/layout/render priority.

That sounds good to me. With that flag, we can also very easily create the widgets I mention. Just like the repaintBoundary is a flag and we create a widget to set it.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T04:12:13Z" retrieveTime="2022-10-15T21:31:00.632251">

> if we have different size of different item, we cannot just show placeholder with same size, scrolling when and after content item is building/layouting may cause a sudden change in list.

That's true. `keframe` workaround by letting the developer specify a placeholder size *manually*. But surely, for complex list items, we can never predict the size in advance so it still "jumps" when real content loads.

Maybe this is inevitable, and we have to live with it? Or, maybe we just place background color on those non-built entries?

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T04:25:56Z" retrieveTime="2022-10-15T21:31:00.632251">

we have to live with it, but we can give some different solutions, such like allow jumps, background color or some other...

I remember that iOS has very high priority with scrolling. If we can get item's size before build, this may not be a problem.

pre-measure for many things is possible but we have two considerations:
- it cannot block UI/main thread otherwise it means nothing
- it should has slice cost for developer to do that

this may conflict with principle of Flutter for single pass measure……but I think it has already has many cases in practice against that, it may not be a big deal.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T05:20:21Z" retrieveTime="2022-10-15T21:31:00.632251">

@xanahopper I am not sure whether that is another isolated problem, or we can directly solve it within our proposal about this issue. For example, if we are to add a pre-measure phase, we may add computeSomething in addition to existing computeLayout, computeDryLayout etc, and that may be orthogonal to this issue.

Btw, I suspect whether pre-measure can happen before `build` phase, since we even do not know the widget tree then. Maybe it can happen before `layout` phase?

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T05:47:02Z" retrieveTime="2022-10-15T21:31:00.632251">

> @fzyzcjy reply to @Nayuta403  I have had similar thoughts before. The problem is, build phase is not the most costly one. There are layout and paint phase, etc, as well. What's worse, Flutter has C++ engine code which rasterizes and flush to the screen. That one can take a long time in some cases (for example, in my own app, when there is a ton of bezier curves). A widget may, for example, have very short build phase time but very long C++ rasterize time.

Just to make it a little bit more detailed: On the contrary, if my proposal above works, the following may happen -

1. Animations are in perfect 60fps, since low-priority job auto pause when near timeout. If we use keframe or similar solution, and give too many widgets in one frame, our animation will stuck.
2. No cpu cycles are wasted, because we will never early-pause but will only pause when near timeout. For example, suppose widget A needs 160ms to build+layout+paint+raster, then it will be done in (roughly) 10 frames. If we use keframe or similar solution, and give too little widgets in one frame, we are wasting cpu cycles.
3. It avoids our need to measure, or guess, the time needed for a widget in build/layout/paint/raster phase. Just as I mentioned above, I personally find it hard to guess how long a widget will need in those phases, especially raster phase which is C++ and varies greatly on different CPU/GPUs (different phones).
4. It is OK to have a non-separable widget that is heavy in one phase.
5. It is automatic and declarative. Programmers only need to specify priorities and that's all.

Btw I also like your (@Nayuta403) keframe solution :) Just trying to propose something that we can make flutter even better

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:09:38Z" retrieveTime="2022-10-15T21:31:00.632251">

@fzyzcjy  Thank you, I think we all want to make Flutter better. ❤️

So I think of a few problems we might have to solve: 
1. How to get the current UI cost, I think we still need to know this information even if we put the animation in the high priority queue, so that we can determine when the low priority task should end. 
2. How does the ListVIew item handle sliding when there is no width and height information 
3. How Fiber builds interruptible. It might be a little easier for a ListVIew, because its items are siblings. But what about parent-child nodes like Container?

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:10:03Z" retrieveTime="2022-10-15T21:31:00.632251">

More thoughts here.

#### 1. For CircularProgressIndicator, or high-priority widgets without low-priority children

A very draft idea:

We may have multiple sub-trees, i.e. have a forest, in flutter. In this example, CircularProgressIndicator may be subtree 1, and everything else may be subtree 2. The subtree 1 goes through build/layout/paint/raster etc for each frame, and subtree 2 may go slowly, i.e. suspend.

Suppose it needs 10 frames for subtree 2 to finish the whole build/layout/paint/raster process. Then, we just allow all inconsistent and dirty states to exist during that 10 frames. For example, a node may have several layouted children and several un-layouted children. Same goes for rasterizing etc. We also need to ensure nobody can mutate the state accidentally when they are dirty.

In addition, I think we may not need to add this suspend feature to the `build` phase, but only add to layout/paint/raster if possible, contrary to React. This is because, if the time-consuming operation is only at build phase, keframe or similar solutions should already work. It may be deep in the rendering pipeline that makes this proposed method more interesting.

Surely this is just a draft and brainstorm, and I am willing to hear any thoughts!

#### 2. For ListView scrolling problem, or high-priority widgets with low-priority children

The problem is, those big low-priority children may need a lot of frames (say 10 frames) to build/layout/paint/rasterize, and during those 10 frames, their internal data structure are not ready for use. For example, we cannot let it to paint at 5th frame, because its layout tree (or layer tree or something like that) may have a child that has been layouted and another child that has not yet been layouted.

However, we are doing nothing but scrolling. Then what about simply *raster cache* the screen, and scrolling is nothing but shifting this `ui.Image`. More details can mimic this PR: https://github.com/flutter/flutter/pull/106621 In that PR, during a "zoom page transition", no real widgets are built in each frame. Instead, a `ui.Image` snapshot is taken in the first frame, and during the whole transition we are just zooming that Image. Our solution is different from #106621, though. In that PR, no work is done during the whole page transition, but in our case, we can perform useful build/layout/paint/raster in the remaining time of each frame.

This solution also has some spirit similar to React Fiber: In Fiber, our JS-driven DOM elements are freezed indeed, and it is the CSS animation that still works. In our case, the "scrolling ui.Image" is a bit mimic a scrolling CSS animation.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:13:41Z" retrieveTime="2022-10-15T21:31:00.632251">

> How to get the current UI cost, I think we still need to know this information even if we put the animation in the high priority queue, so that we can determine when the low priority task should end.

Seems we do not need? We just blindly run whatever should be done next, and suspend when we are near 16ms.

We do need to let the the high priority job (say CircularProgressIndicator or ListView-scrolling) finish within the totally 16ms though.

My first thought is that, it would be best if we execute *all phases* of *this subtree* first, and then execute (and suspend when timeout) all phases of the second subtree in whatever time remain. Then we never need to get the cost.

If that is impossible, I wonder whether we can use some heuristics. We all know a CircularProgressIndicator should be very lightweight, so is a ListView-scrolling (if using the ui.Image approach above). We may also learn from the history.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:15:32Z" retrieveTime="2022-10-15T21:31:00.632251">

> How does the ListVIew item handle sliding when there is no width and height information

If using the approach mentioned above, it will just be blank. But not blank whenever there is a scrolling! Because we know Flutter has some cache extent for ListViews, we can also capture those cached extents in our `ui.Image` snapshot. Then, only if the following happens, we will see blank:

1. The user scrolls so much that all cache extent are used up
2. Our heavy widgets are so heavy that it even does not finish one frame up to now

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:18:41Z" retrieveTime="2022-10-15T21:31:00.632251">

> How Fiber builds interruptible. It might be a little easier for a ListVIew, because its items are siblings. But what about parent-child nodes like Container?

As a very rough draft, I am considering `yield`. For example:

```dart
Iterable<void> performLayout() sync* {
  yield* myFirstChild.layout();
  some_computation_here;
  yield* mySecondChild.layout();
}
```

Each yield point is suspendable.

IIRC, Redux Saga https://redux-saga.js.org/docs/introduction/BeginnerTutorial/ uses something similar to this.

Have not digged into React Fiber's source code yet. Have you checked it, how does it implement it?

But as I am not an expert in Dart compiler implementation, I am not sure about the performance penalty. (Hope it to be tiny!)

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:31:44Z" retrieveTime="2022-10-15T21:31:00.632251">

A few pointers:

- We cannot use sync generators, they create code that is large and slow. 
- A good canonical case here would be something like https://github.com/flutter/flutter/blob/master/dev/benchmarks/macrobenchmarks/lib/src/list_text_layout.dart. This ends up being janky because layout gets expensive for all that text (on a lower end phone it can easily take 20-30+ms just to layout all the text there, and the ListTile is a little deceptive because Material introduces expense - this is the kind of thing we want to figure out how to break up "automatically").
- We should probably worry about prioritization of jobs until after we figure out how to sensibly budget and interrupt layout/painting/compositing. It doesn't matter what priority we'd want to give things if we can't do that, and it will probably be hard to come up with a good/fair prioritization scheme.


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:40:01Z" retrieveTime="2022-10-15T21:31:00.632251">

@dnfield Thanks for the ideas!

> how to sensibly budget and interrupt layout/painting/compositing.

Quick answer to budget: As suggested in my comments above, we may not need to budget things (unlike the keframe-like solution). We just run the high-priority subtree (one with animation) until it finishes, and then run low-priority heavy subtree until whenever timeouts.

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:42:05Z" retrieveTime="2022-10-15T21:31:00.632251">

Animations might not ever finish.

</DiscussionComment>

<DiscussionComment author="dnfield" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:42:34Z" retrieveTime="2022-10-15T21:31:00.632251">

And you might be animating the entire screen, e.g. for a route transition

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:43:27Z" retrieveTime="2022-10-15T21:31:00.632251">

> Animations might not ever finish.

Well, I mean, run its build+layout+paint+raster fully instead of partially, not wait until there is no animations at all. For a CircularProgressIndicator it may take, say, <1ms. The rest 16.66-1=15.66ms will be given to low-priority subtree.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:44:23Z" retrieveTime="2022-10-15T21:31:00.632251">

> And you might be animating the entire screen, e.g. for a route transition

That sounds similar to the "a scrolling ListView" example above in https://github.com/flutter/flutter/issues/101227#issuecomment-1247625317. Just as mentioned there (and a little bit similar to https://github.com/flutter/flutter/pull/106621), we may take a snapshot of the heavy children, when the heavy widgets are rebuilding.

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:52:42Z" retrieveTime="2022-10-15T21:31:00.632251">

> Seems we do not need? We just blindly run whatever should be done next, and suspend when we are near 16ms.

Well, I think there should be a timer for how long the UI is currently built, since you also mentioned `near 16ms`, and the `remaining time`. I think it's easier (and that's what I'm going to try) if I just count the time spent on the framework. But as you say, the problem becomes more complicated when you consider the Raster thread.





</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T06:55:41Z" retrieveTime="2022-10-15T21:31:00.632251">

> Well, I think there should be a timer for how long the UI is currently built

I guess that is easy :) Maybe as simple as `DateTime.now()`, but probably there are something with higher precision etc.

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T07:08:13Z" retrieveTime="2022-10-15T21:31:00.632251">

> @Nayuta403 I have had similar thoughts before. The problem is, build phase is not the most costly one. There are layout and paint phase, etc, as well. What's worse, Flutter has C++ engine code which rasterizes and flush to the screen. That one can take a long time in some cases (for example, in my own app, when there is a ton of bezier curves). A widget may, for example, have very short build phase time but very long C++ rasterize time.

Yes, the timing of the statistical framework is not complicated, so I'm just trying to perform more tasks in a frame based on that time, regardless of Raster


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T07:10:21Z" retrieveTime="2022-10-15T21:31:00.632251">

> @Nayuta403 Yes, the timing of the statistical framework is not complicated, so I'm just trying to perform more tasks in a frame based on that time, regardless of Raster

Sorry I do not quite get it. Are you using history timing information to estimate future timing?

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T07:38:31Z" retrieveTime="2022-10-15T21:31:00.632251">

It's Keframe. I'm trying to count the time it takes to `build/layout/paint` item widgets so that each frame can be rendered as many times as possible (currently only one item per frame is rendered). 
(Am I making myself clear? (*￣︶￣))


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T07:43:51Z" retrieveTime="2022-10-15T21:31:00.632251">

@Nayuta403 Clear :)

So seems that it is based on history. Then what if different items have (very) different time needed? That happens frequently IMHO. For example, suppose we have a ListView of posts. Post 1 may be a simple sentence so it is fast. Post 2 may be a long rich text paragraph and complex Paths etc, so it is slow.

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T07:57:05Z" retrieveTime="2022-10-15T21:31:00.632251">

Yes, you are absolutely right, because now every task is setState() and only goes back to rendering the real widget on the next frame. One idea I have now is to make this task a real rendering task, similar to marking it as dirty and then executing drawFrame() to get the real time.

I can create an issue later to describe my thinking in detail and make the issue clearer  :>

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T08:00:57Z" retrieveTime="2022-10-15T21:31:00.632251">


> I can create an issue later to describe my thinking in detail and make the issue clearer :>

Looking forward to it :)

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T09:39:44Z" retrieveTime="2022-10-15T21:31:00.632251">

#### More about "how to build suspendable/interruptable", given that sync generators are slow

Is it possible we create a `RenderSuspendable` RenderObject (and corresponding Suspendable widget) which does the following:

1. Users need to insert this widget into tree whenever they want suspendable. This may be reasonable given this spirit is similar to RepaintBoundary. And users will not need to insert too much, just insert at coarse subtrees. 
2. It behaves like a most naive proxy render box in normal cases.
3. When time is near used up, and when RenderSuspendable.layout is called, it will *not* call child.layout, but instead set a flag (say `needsLayoutLaterWhenPossible`) and directly return. As for the return value, it may return the last layout size or user-defined default size (similar to what keframe does in widget-build level). By doing this, ancestor render objects will be happy and finish its layout function very fast.
4. For a `RenderSuspendable` with `needsLayoutLaterWhenPossible=true`, when a new frame comes in, it will `this.markNeedsLayout()`, and thus get a chance to execute its `layout` method again in this new frame. If time is enough, it is done normally as in "2.", and the needsLayoutLaterWhenPossible is cleared; otherwise, it is done as in "3.".

Remark: May need a tweak a bit about `layout`'s caching mechanism.

Remark: RenderSuspendable's sub-tree will *not* be redundantly layouted more than once. For example, say we have a `Column` with two `Suspendable` children, the first one has done layout, and the second one does not because of timeout. Then, when the next frame comes, Suspendable 2 calls markNeedsLayout, and Column starts performLayout. Then Suspendable 1 *does* have layout() called. However, we should recognize it (possibly flutter caching already does so?), and no need to layout its child at all.

**Features**

* Solves the problem of "how to build suspendable/interruptable", without sync generators
* No need to modify existing render objects, only need to add a new one

**Potential problem**

Unnecessary (i.e. redundant) relayout will happen for ancestors of Suspendable, until meeting a relayout-boundary.

Not sure how large the penalty is. If we can give near enough relayout boundary, looks like it is no problem? In addition, if we wrap *all* expensive subtrees into Suspendables, then the rest may be quite cheap.

**How is layout / paint / rasterize related?**

Done one by one. Layout of *everything* will be firstly finished. Only after that, we start doing painting of everything. And then rasterizing.

**What about paint tree? layer tree? engine(c++) rasterizer?**

TBD, I guess will be similar to above. Looking forward to hearing some feedbacks about the approach for layout first!

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T09:57:10Z" retrieveTime="2022-10-15T21:31:00.632251">

#### How can we paint UI onto screen, if we are in half-way of layout/paint/rasterize, and many nodes are dirty / half-way updated?

Basically I have two draft ideas:

Firstly, we may hack the Flutter engine. Let it keep the old content available until the new content is *fully* available.

Secondly, we may be able to solve it without big modifications to engine. We may just "take a screenshot" before starting the journey of heavy updating. For example, suppose we need 10 frames to fully build/layout/paint/rasterize this widget subtree. Then, we use the new `toImageSync()` to take a photo of it. Then, during the 10 frames, we can do anything to the render/layer/engineLayer trees, and whenever the parents let us to paint, we just canvas.drawImage() using that. After 10 frames when we are done, we will finally paint the new thing.

By the way, this also has a bonus about *predictable time consumption*. IMHO, the time of drawing (paint+rasterize+...) a `ui.Image` may be easily computed, given it is nothing but a rasterized image.

---

@dnfield Given that you implemented this great new `toImageSync` feature (https://github.com/flutter/engine/pull/33736), I have a question about its performance: 

In the solution above, instead of painting normally, we may have to convert child into `ui.Image` for each and every `paint` call.

In other words, in pseudo code:

```dart
class OurRenderObject {
  void paint() {
    // child.paint(); // cannot do this

    if (everything_is_not_dirty) {
      image = toImageSync(child_render_tree); // save a screenshot
    }

    // ...do some expensive work here if time is sufficient...

    canvas.drawImage(image);
  }
}
```

So, will this have performance penalty or not?

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-15T14:41:50Z" retrieveTime="2022-10-15T21:31:00.632251">

Looking forward to some early feedbacks about the proposal :)

Maybe /cc @dnfield @JsouLiang @Nayuta403 @xanahopper (based on today's activity)

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T00:57:12Z" retrieveTime="2022-10-15T21:31:00.632251">

P.S. I am starting to work on a prototype about smoothing the "layout" phase. Will report any progress I make :)

Code: https://github.com/fzyzcjy/flutter/tree/feat-smooth

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T04:06:27Z" retrieveTime="2022-10-15T21:31:00.632251">

### Progress: 62ms -> 22ms for 99th build time of `list_text_layout`, and its limitations

(Limitations is discussed in the last section of this comment)

The `list_text_layout` is still too fast on my old android, so I enlarged its scale (have more items in column, more text in each item, etc) a little bit. Code is seen in https://github.com/fzyzcjy/flutter/commit/857210213531e76b3eb5c256a8ef3599ed434703. This yields:

```
{
  "average_frame_build_time_millis": 2.8446626506024097,
  "90th_percentile_frame_build_time_millis": 1.213,
  "99th_percentile_frame_build_time_millis": 62.531,
  "worst_frame_build_time_millis": 63.101,
  "missed_frame_build_budget_count": 14,
  "average_frame_rasterizer_time_millis": 3.296915662650604,
  "90th_percentile_frame_rasterizer_time_millis": 8.09,
  "99th_percentile_frame_rasterizer_time_millis": 13.82,
  "worst_frame_rasterizer_time_millis": 15.178,
  "missed_frame_rasterizer_budget_count": 0,
  "frame_count": 249,
  "frame_rasterizer_count": 249,
  "new_gen_gc_count": 34,
  "old_gen_gc_count": 4,
  "frame_build_times": [
```

![image](https://user-images.githubusercontent.com/5236035/190553671-b44adef7-3cab-49db-95bc-45cfc15ad5a9.png)

Then, I implement a proof-of-concept Suspendable. Code is at https://github.com/fzyzcjy/flutter/commit/0babd5b6856bc799c9f369bce75aada7c10fcd0b. Code diff can be found in https://github.com/flutter/flutter/compare/master...fzyzcjy:flutter:feat-smooth?expand=1.

It yields:

```
{
  "average_frame_build_time_millis": 4.24028,
  "90th_percentile_frame_build_time_millis": 17.769,
  "99th_percentile_frame_build_time_millis": 22.235,
  "worst_frame_build_time_millis": 23.829,
  "missed_frame_build_budget_count": 41,
  "average_frame_rasterizer_time_millis": 3.9516548672566385,
  "90th_percentile_frame_rasterizer_time_millis": 8.949,
  "99th_percentile_frame_rasterizer_time_millis": 11.202,
  "worst_frame_rasterizer_time_millis": 11.604,
  "missed_frame_rasterizer_budget_count": 0,
  "frame_count": 225,
  "frame_rasterizer_count": 226,
  "new_gen_gc_count": 17,
  "old_gen_gc_count": 4,
```

![image](https://user-images.githubusercontent.com/5236035/190553863-5a373dcb-75ba-468d-8118-66e7a393070b.png)

---

### Limitations

This is just proof-of-concept and is very naive.

* It only suspends the layout and build phase. (The build phase is wrapped inside layout phase by adding a LayoutBuilder.) Indeed, it does not suspend the paint or raster phase, which should be done in future work.
* It paints nothing (i.e. do not call child.paint) if a Suspendable is suspending. This will destroy the layer tree and C++ engine layer trees, making performance much worse. We should address this problem later, possibly by keeping the layer tree not used but not removed.
* It lets the whole ancestors (up until relayout-boundary) to relayout in each frame.
* Overhead will become non-neglectable, if we want it to run in 60fps. In other words, if we want each frame to be under 16ms, looks like we will only have <10ms for handling the suspendable widgets (rough estimate, but anyway numbers differ on different phones). Then, the price of 60fps smooth animation is that, the suspendable needs longer time to be loaded.
* The current implementation does not run suspendable layouts *last*. Instead, they are run inside non-suspendable layout. Thus, we have to set a "earlier" deadline (e.g. 12ms, instead of 16.6ms in the example above), and hope that the remaining job will finish quick enough.
* [Element.performLayout](https://api.flutter.dev/flutter/rendering/RenderSliverScrollingPersistentHeader/performLayout.html) says, "In implementing this function, you must call layout on each of your children". But, when implementing Suspendable, we have to violate this. We will face troubles, or just minor changes are enough?
* If a child under Suspendable mark itself as needed to relayout/rebuild, and there is relayout boundary between that child and Suspendable, then the suspending mechanism will not work at all.
* Originally all code (implicitly) assume that, when a frame ends, build/didUpdateWidget has been called. But now this no longer holds. That will make a ton of widget fail to work, including those inside flutter framework, and many external packages. For example, those who assume this inside their addPostFrameCallback.
* The demo does not yet provide any animations (e.g. a CircularProgressIndicator), so by merely looking at the screen, we cannot see it becomes much smoother ;)

</DiscussionComment>

<DiscussionComment author="JsouLiang" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T06:49:08Z" retrieveTime="2022-10-15T21:31:00.632251">

Furthermore, I think should we able to break the Build call if the Widget is complex and the Widget Build call is too deep and stalling?

@fzyzcjy 


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T07:15:11Z" retrieveTime="2022-10-15T21:31:00.632251">

### New idea: Dual isolates

(This comment is updated)

#### Advantages

The main goal is similar: No matter how heavy your widget build/layout/... is, animations/gestures should be 60fps.

It does not require existing Flutter/Dart code to accept new assumptions. For example, in the old proposal, the `layout` may *not* be called within a frame, and thus `build` will also not be called. This may violate many existing code. For example, `addPostFrameCallback` may assume build is done when post-frame.

On the contrary, the "Dual isolates" solution will not have those assumptions at all. It seems **not to break existing explicit or implicit assumptions about the code**. Except that it will make Dart isolate "freeze" once in a while - but that should not be a problem, since we are all happy with stop-the-world GC and OS's suspending a thread.

In addition, it should have much lower overhead, indeed almost zero. No wasted build/layout happens (unlike RenderSuspendable approach). No unnecessary tree destory and recreate happens.

#### Background

The approach above, with the minimal sample in https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781, has many known problems which I am not sure whether can all be overcome. I will probably also experiment further on that path as well. At the same time, I find out a new approach without most problems above.

I am not an expert in `flutter/engine`, so please correct me if I am wrong!

#### Design

Originally, IMHO we have a UI thread, which runs both C++ code and Dart main isolate code. Now, we have three (but no worries, they will not be parallel most of the time!):

* C++ UI thread.
* Dart main isolate: Run everything you know, i.e. the heavy build/layout/paint/.... Say it takes 2 frames to finish.
* Dart sidecar isolate: Run CircularProgressIndicator, or ShiftTheChild(for scrolling ListView, to be explained below).

An UML diagram is attached below (best read with text explanations here).

Here is what happens when a vsync comes in:

* C++ ui thread receives the vsync. In the old days, it will call dart's DrawFrame. But now, it will set up a timer for a bit less than ~16.67ms (say 15ms), pause self thread, and call Dart main isolate's DrawFrame.
* Dart main isolate's DrawFrame starts running. It runs build/layout happily.
* At 15ms, timer wakes up C++ ui thread. C++ ui thread then immediately "pause" the dart main isolate. This is done by "safepoints". In other words, we insert `safepoint()` call to `layout()` function of Dart RenderObjects. And that function is a native function reading, say, a mutex lock. When C++ ui thread wants to pause the dart main isolate, it simply acquire the mutex. When Dart goes to the next safepoint() call, it will simply be pause there forever waiting to acquire the mutex (until next frame indeed).
* C++ ui thread calls sidecar isolate to compute the whole build/layout/paint procedure. This is done serially now for simplicity, but should be easily parallizable with some locks.
* Sidecar Dart code is a bit different from the traditional widget/renderobject/layers. Instead, it knows which EngineLayer it owns, and only mutates it. For example, for a CircularProgressIndicator in sidecar, it will know it owns a DisplayListLayer, and only modify pictures in it, without touching other layers. For a ShiftTheChild, it owns a OffsetLayer and modifies its offset.
* Now go back to our C++ ui thread. We will simply utilize the current engine layer tree in C++, and the rest is the same, such as giving data to rasterizer thread and render to the screen.

This is not the end of story - notice our main isolate is still computing some layout and is hanging. Now suppose 2nd vsync comes in.

* Again, C++ ui thread receives vsync. It notices there is still remaining job in main isolate. Then it just resume the main isolate, without telling it anything about the second frame. Thus, in the eyes of main isolate, it will think the whole phone just "freezed" for a few milliseconds without other problems, and will happily continue build/layout/etc.
* Suppose the heavy job of the main isolate is finally finished in this frame. Then, it will do painting. In other words, it will mutate the Layer tree in C++ code. We deliberately put no safepoint() during painting, so the C++ layer tree will either be non-mutated or fully-mutated without intermediate case.
* The rest is similar to the first frame, except that our engine layer tree is updated to the new one.

#### Further improvements

* sidecar isolate should be executed concurrently
* main isolate should also be executed concurrently, with locks protecting critical regions such as mutating the engine layer tree. But otherwise, it should run freely. By doing this, we are guaranteed that, we can let main isolate run using almost a full cpu core. On the contrary, the "RenderSuspendable" approach above will only give, say, 10.67ms out of 16.67ms for heavy widget build/layout, because it need (say) 6ms to paint/rasterize existing things.

#### What is `ShiftTheChild`

I want to solve the problem of "ListView scrolling". In other words, when scrolling a ListView, the widget build/layout may be arbitrary heavy, while we should get 60fps.

Thus, let us do the following:

```dart
ParentWidgets(
  child: ShiftTheChild(
    child: ListView.builder( ... )
  )
)
```

Suppose ListView subtree takes 10 frames to rebuild/layout/etc, and suppose the user is scrolling it. Then, during the 10 frames, ShiftTheChild will receive data packets about user dragging and perform a shift (i.e. OffsetLayer's offset) to its child content. ShiftTheChild will be in the sidecar isolate.

P.S. It may not even be a widget or RenderObject, but may be built on some other lower level primitives mutating corresponding C++ engine Layer. But surely we can wrap those primitives and maybe create a RenderSidecar or something new, that should not be a problem.

#### Minimal example

I plan not to implement sidecar isolate in the minimal example. Instead, just create a C++ function that shifts an OffsetLayer in each frame, as if a sidecar isolate is doing so. This is because the sidecar isolate is nontrivial engineering work but is not the core problem.

---

#### UML Diagram

![UML](https://user-images.githubusercontent.com/5236035/190575625-cac7fa73-0b80-4808-8414-130446ad8884.png)


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T07:15:58Z" retrieveTime="2022-10-15T21:31:00.632251">

@JsouLiang For the "RenderSuspendable" proposal, I guess we can have nested ones. For the "Isolates" proposal just now, I guess we do not have this problem - the main isolate will be paused at *any* safepoint, i.e. *any* layout function.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T07:20:48Z" retrieveTime="2022-10-15T21:31:00.632251">

@dnfield @JsouLiang @Nayuta403 (and other engine masters)

For the new proposal, I hope to see some feedback... Since I am not an expert in `flutter/engine` (and few materials are about it on the internet). Thus:

1. Is there any suggested materials (docs/articles/...) to understand the engine? How do you learn the engine?
2. Does my proposal above looks OK?

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T09:23:36Z" retrieveTime="2022-10-15T21:31:00.632251">

> @JsouLiang For the "RenderSuspendable" proposal, I guess we can have nested ones. For the "Isolates" proposal just now, I guess we do not have this problem - the main isolate will be paused at _any_ safepoint, i.e. _any_ layout function.

multiple isolates is one of my optimize and working in progress, the key to this is some build/layout callback function/method should not be called in non-main isolate, or just serialize/deseralize build/layout request and response to another isolate like a local RPC service.
But! Multiple isolates may agains Flutter's principle, I don't sure whether it can be merged.

(Dude, you are really high-producing and I'm reading your new comments try to catch up

And for more, I may offer you some complex card widget case for benchmark.

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T09:59:40Z" retrieveTime="2022-10-15T21:31:00.632251">

For this Suspendable render, we may introduce structure like Fiber, I think it is [Threaded tree](https://en.wikipedia.org/wiki/Threaded_binary_tree).

First thing to drawing a frame including heavy/suspendable part is transform tree to a list (or just a threaded tree)

![image](https://user-images.githubusercontent.com/2241197/190613080-dfaa31f1-82ca-4c8e-8fb1-ac68fc4cada2.png)

Render task 5 and 6 should and can be suspended at any place in it. (What if a widget/node cost timeout?)

we can tell from figure that suspendable is contagious, content in suspendable cannot be non-suspendable.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T10:27:32Z" retrieveTime="2022-10-15T21:31:00.632251">

@xanahopper 

> multiple isolates is one of my optimize and working in progress

Looks interesting, could you please share the link? I have checked your github but seems cannot find anything. (All my Flutter work are done open-source and can be found at my github).

> the key to this is some build/layout callback function/method should not be called in non-main isolate, or just serialize/deseralize build/layout request and response to another isolate like a local RPC service.

Could you please provide an example? Thanks

Btw, my solution does not use non-main isolate with callbacks :) Indeed, I only put CircularProgressIndicator and ShiftTheChild and things like that there. No normal user code should be done in the sidecar isolate, because otherwise it is quite unfriendly to the users (the sidecar isolate has no memory sharing w/ the main isolate).

So I hope it is not a blocker!

> But! Multiple isolates may agains Flutter's principle, I don't sure whether it can be merged.

Could you please elaborate a little bit more?

My solution is still mainly single-isolate, and the sidecar isolate (as mentioned above) is just used very limitedly to support animations.

In addition, my multi-thread is still mostly serialized instead of parallel running. There are multiple threads, simply because I want to suspend/pause one thread easily.

> Dude, you are really high-producing and I'm reading your new comments try to catch up

Haha take your time! It takes me a day thinking and trying all these things :)

> And for more, I may offer you some complex card widget case for benchmark.

Sure, looking forward to that. Btw I also have very complex cases for my own app, but I decide to start from the simple - you know, one of the fundamental rules in software engineering.



</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T10:35:09Z" retrieveTime="2022-10-15T21:31:00.632251">

> @xanahopper's comment in https://github.com/flutter/flutter/issues/101227#issuecomment-1249172293

If I understand correctly, the figure is a bit like a extended version of my prototype https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781 above.

The question is, how are you going to transform a tree to a (suspendable) list - In other words, for example, how to make subtree rooted at 5 become a list that *can be paused*?

I have proposed using `yield` in `performLayout` but @dnfield mentioned it is very slow. Given that your suspendable widgets are contagious, we cannot use yield at all (otherwise we will be using it in a big subtree).

Then in my prototype above I decide to let a Suspendable return zero size when it is near timeout (note: different from your figure, but the problem to solve is similar). But such approach seems not possible for your proposal.

This is solved very easily with my "Dual isolates" proposal. It just call `safepoint()` in every RenderObject's `layout()`. Then, whenever the C++ code wants to suspend Dart, C++ will just let `safepoint()` hang (probably by occupying a mutex). Then Dart code is just hang there, without doing anything, without feeling anything. In Dart code's view it is like a stop-the-world GC indeed.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T10:43:25Z" retrieveTime="2022-10-15T21:31:00.632251">

@wangying3426 https://github.com/flutter/flutter/issues/101227#issuecomment-1240156979

> Any update please? We are also interested in this feature.

Btw I forget to mention you (too above in the comments). Yes, now I have many updates :)

</DiscussionComment>

<DiscussionComment author="xanahopper" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T11:08:52Z" retrieveTime="2022-10-15T21:31:00.632251">

Multiple isolates and optimize with it is before the specification phase, just for you known that we both have the same idea that I and my colleagues are working on it. for very early part we think that this way may need modify engine or even the Dart VM.

Last time we coming with a issue [#110063](https://github.com/flutter/flutter/issues/110063) and got a refuse with tough attitude.

## Transform

When we need _build_ a Widget, we must already got a widget or state(element), that means we have a _factory_ for children widgets.
All Flutter's build (as long as other declaration UI) is a function call, just like

> UI = f(g(h(state)))

We just change this to 

> ui1 = h(state)
> ui2 = g(ui1)
> UI = f(ui2)

wrap ever build into a node/task and change all that to a chain list. In practice, we can use a deque to collect deeper call.

### Widget tree build:
1. Got a node to build from queue, we dont know whether it will be a leaf node.
2. Execute node's build, add all children to queue.
3. Add executed node to a deque tail.
4. Repeat goto 1

### Element & RO tree build
Because elements generally need children to be ready, so we have to produce it from leaf.
1. Take a node from tail of executed node deque(this will like a stack)
2. Produce Element/RenderObject
3. repeat

It just like traversal a tree without recursion, so we can suspend and resume at any iteration of traversal.
this is a prototype of pseudo code, hope it help.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T11:42:29Z" retrieveTime="2022-10-15T21:31:00.632251">

@xanahopper 

> Multiple isolates and optimize with it is before the specification phase, just for you known that we both have the same idea that I and my colleagues are working on it. for very early part we think that this way may need modify engine or even the Dart VM.
Last time we coming with a issue https://github.com/flutter/flutter/issues/110063 and got a refuse with tough attitude.

I see. Willing to collaborate to make it into reality as soon as possible!

I looked at #110063 now. If I understand correctly, seems that @jonahwilliams refuses because "Splitting the UI thread work into multiple theads is infeasible for several reasons", such as "a single thread means that newspace allocations don't need any locking". However, my proposal above deliberately avoids these problem. In my case, the c++ ui thread is sleeping while dart main isolate is running, and (if flutter does not like multi concurrent isolates) the thread and main isolate can also be sleeping while dart sidecar isolate is running. So, we are still running single isolate, and no lock is needed at all!

In short, I am not using multi threading. Instead, all threads are there only to implement suspending.

> or even the Dart VM.

This inspire me of something: If we can implement a suspend mechanism in Dart VM, maybe we do not need that safepoint + one extra thread approach.

> Widget tree build

Fully understand now :) That should be very workable, just like React Fiber does.

> Element & RO tree build
so we have to produce it from leaf
Produce Element/RenderObject

Sorry I do not get it. We are not going to produce RenderObjects, but (most of the time) *modify* (update) them. For example, say you have a RenderPadding. Then we will only modify its padding field and markNeedsRelayout, instead of throwing away the old padding and create a new one.

Most importantly, how can we get the BoxConstraints (suppose we are dealing with RenderBox)? For example, when we are `layout()` for a leaf, we must know the BoxConstraints its parent wants to give it. But the parent is not yet `layout`ed.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-16T11:46:14Z" retrieveTime="2022-10-15T21:31:00.632251">

@xanahopper In addition, I have mentioned many limitations of the suspendable tree traversal in https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781 (see last section there). Looking forward to see some solutions about it!

For example, a big problem: Originally all code (implicitly) assume that, when a frame ends, build/didUpdateWidget has been called. But now this no longer holds. That will make a ton of widget fail to work, including those inside flutter framework, and many external packages. For example, those who assume this inside their addPostFrameCallback.

---

**Update**: More problems are added to that comment. For example, "If a child under Suspendable mark itself as needed to relayout/rebuild, and there is relayout boundary between that child and Suspendable, then the suspending mechanism will not work at all."

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T00:41:55Z" retrieveTime="2022-10-15T21:31:00.632251">

**Update**: I am thinking whether we can remove the need of new threads in https://github.com/flutter/flutter/issues/101227#issuecomment-1249005541. If we can pause a Dart isolate without needing new threads, we can remove those threads.

Details can be found in:

* https://github.com/dart-lang/sdk/issues/49981

---

**Update**: I am trying to use the spirit of stackful coroutines to implement it.

I do get stuck. We have a ton of callbacks from C++ calling into Dart, such as when the image data has been loaded successfully. If the dart main isolate is freezed (either by stackful coroutine, or by a normal thread with mutex), C++ code cannot call Dart at all. Delaying those calls also seem very troublesome because of resource deallocation problems.

---

**Update**: Search a bit on Discord history and here is a summary.

* [cannot find earlier discussions]
* 20220111-20220114, hackers-framework, mentioned in [20220520](https://discord.com/channels/608014603317936148/608014603317936150/976924283685199902) by hixie, https://discord.com/channels/608014603317936148/608021234516754444/930241489374683157
* [not found] "Hixie tried an experiment that didn't seem to get to a working point", [said here](https://discord.com/channels/608014603317936148/613398126367211520/977090864813846548), but I cannot find the experiment code
* 20220520, "general" https://discord.com/channels/608014603317936148/608014603317936150/977074969542553600
* 20220520, "hackers-performance-", with a pointer to "general" as previous discussions, https://discord.com/channels/608014603317936148/613398126367211520/977109431408009317

Well I see some parts of my experiment above has already been discussed there

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T08:02:13Z" retrieveTime="2022-10-15T21:31:00.632251">

### Rethinking (overcoming) the shortcomings of [the `Suspendable` "62ms->22ms" experiment](https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781)

The quoted text are the shortcomings mentioned in the experiment, and black text are my re-thoughts.

> It only suspends the layout and build phase. (The build phase is wrapped inside layout phase by adding a LayoutBuilder.) Indeed, it does not suspend the paint or raster phase, which should be done in future work.

Given the [discord discussions](https://github.com/flutter/flutter/issues/101227#issuecomment-1249961627) among @Hixie and @dnfield etc, seems build/layout is mostly the expensive one. So paint or raster may not needed to be considered at the highest priority, at least not implemented in this issue and may defer to future work.

> It paints nothing (i.e. do not call child.paint) if a Suspendable is suspending. This will destroy the layer tree and C++ engine layer trees, making performance much worse. We should address this problem later, possibly by keeping the layer tree not used but not removed.

This is not a problem if we only consider the jank caused by widget creation/deletion (like going to a new page or ListView scroll to make a new widget visible).

> It lets the whole ancestors (up until relayout-boundary) to relayout in each frame.

But I guess this should not be a big problem in real world, because we should keep the heavy things in Suspendable subtrees and keep the ancestors simple.

> Overhead will become non-neglectable, if we want it to run in 60fps. In other words, if we want each frame to be under 16ms, looks like we will only have <10ms for handling the suspendable widgets (rough estimate, but anyway numbers differ on different phones). Then, the price of 60fps smooth animation is that, the suspendable needs longer time to be loaded.

However, if we want to keep it single-threaded (single isolate), as #110063 (multi isolate) is refused, this is the price we have to pay.

> If a child under Suspendable mark itself as needed to relayout/rebuild, and there is relayout boundary between that child and Suspendable, then the suspending mechanism will not work at all.

We should add more Suspendables if we observe such situation. More specifically, we should add a Suspendable (or, if using `keframe`-like solution, the FrameSeparateWidget) near that specific widget. Then, this is no longer a problem.

p.s. This is not a problem if we only consider the jank caused by widget creation/deletion (like going to a new page or ListView scroll to make a new widget visible).

> The current implementation does not run suspendable layouts *last*. Instead, they are run inside non-suspendable layout. Thus, we have to set a "earlier" deadline (e.g. 12ms, instead of 16.6ms in the example above), and hope that the remaining job will finish quick enough.

Not a critical problem indeed.

> [Element.performLayout](https://api.flutter.dev/flutter/rendering/RenderSliverScrollingPersistentHeader/performLayout.html) says, "In implementing this function, you must call layout on each of your children". But, when implementing Suspendable, we have to violate this. We will face troubles, or just minor changes are enough?

Will see whether it is a problem after doing more experiments.

> Originally all code (implicitly) assume that, when a frame ends, build/didUpdateWidget has been called. But now this no longer holds. That will make a ton of widget fail to work, including those inside flutter framework, and many external packages. For example, those who assume this inside their addPostFrameCallback.

Since this feature is completely opt-in (you have to manually put the Suspendable widget into your tree), users may be able to migrate their widgets when they decide to use Suspendable.

The problem is, it may take efforts to migrate each and every widget, and it also takes time to migrate all inside flutter framework itself. Luckily, it is opt-in, so we can do it steadily and slowly, just like how we migrate to `Material 3` theme (it has been months but still not finished).

Many code may migrate smoothly without any problem. (For example, I personally used MobX for my Flutter app, which has reactive states and automatic rebuild, so I seldom touch the raw frame callbacks. For many widgets in flutter framework we can reason about it in our heads and they seem ok as well.)

We may need to provide some information to the users, indeed `State`s or `BulidContext`s, telling them they have been suspended. A simple method may be adding a field to `State/BuildContext`, or use a `InheritedWidget`. I may defer this work after seeing what info a real widget wants when migrating real widgets.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T11:46:14Z" retrieveTime="2022-10-15T21:31:00.632251">

### Enhance `keframe`: Now seems it can build/layout as many items as possible until time is up, i.e. have strategy similar to the ["layout" proposal](https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781) above

@Nayuta403 

#### The problem

As is discussed in https://github.com/LianjiaTech/keframe/issues/12#issuecomment-1238873216 and (IIRC) earlier comments, `keframe` now blindly builds one widget per frame, even if it can build (for example) 5 widgets. This makes the UI need much longer time to display fully. In addition, it always lag by one frame, because it uses setState in a addPostFrameCallback to update its widget.

#### The solution

IMHO, the following suggestion can avoid the problems above. Now it can build/layout as many items as possible until time is up, i.e. have strategy similar to the "layout" proposal above. Please correct me if I am wrong!

As can be seen in the code example below, the key point is a `LayoutBuilder` wrapped as parent of `FrameSeparateWidget`. By doing so, we ensure that the build *and layout* phase of widgets prior to the current widget has already been done. Now, FrameSeparateWidget can do a simple decision in its `build` method - if time is sufficient just return new child, otherwise return the old one and rebuild in the next frame.

By the way, this is partially equivalent to the "layout" proposal because of the following: IMHO, the `builder` callback inside a `LayoutBuilder` is called within `performLayout`. Therefore, the `build` of the child widget is strongly related to the `layout` of the LayoutBuilder render object. Then, I can partially migrate the idea in the "layout" proposal (where I hacked the performLayout) to this case (where I hack the build).

#### Full code example and output

The dummy `timeRemain` simulates the real world where we may have (e.g.) 16ms for each frame.

<details>

```dart

// ignore_for_file: avoid_print, no_runtimetype_tostring

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

late int timeRemain;

void main() {
  testWidgets('example', (tester) async {
    print('frame #1');
    timeRemain = 3;
    await tester.pumpWidget(MaterialApp(
      home: Column(
        children: [
          for (var i = 0; i < 5; ++i)
            LayoutBuilder(
              builder: (_, __) => FrameSeparateWidget(
                name: '$i',
                child: i.isOdd ? SlowBuildWidget(name: '$i') : SlowLayoutWidget(name: '$i'),
              ),
            ),
        ],
      ),
    ));

    print('frame #2');
    timeRemain = 3;
    await tester.pump();

    print('frame #3');
    timeRemain = 3;
    await tester.pump();
  });
}

// the `keframe` one
class FrameSeparateWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const FrameSeparateWidget({super.key, required this.child, required this.name});

  @override
  State<FrameSeparateWidget> createState() => _FrameSeparateWidgetState();
}

class _FrameSeparateWidgetState extends State<FrameSeparateWidget> {
  @override
  Widget build(BuildContext context) {
    if (timeRemain > 0) {
      print('$runtimeType#${widget.name} build: time is ok, give normal child');
      return widget.child;
    } else {
      print('$runtimeType#${widget.name} build: time is up, give dummy');
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
      return Container();
    }
  }
}

class SlowBuildWidget extends StatelessWidget {
  final String name;

  const SlowBuildWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    print('$runtimeType#$name simulates slow build (timeRemain: $timeRemain -> ${timeRemain - 1})');
    timeRemain--;
    return Container();
  }
}

class SlowLayoutWidget extends SingleChildRenderObjectWidget {
  final String name;

  const SlowLayoutWidget({super.key, super.child, required this.name});

  @override
  RenderSlowLayout createRenderObject(BuildContext context) => RenderSlowLayout(name: name);

  @override
  void updateRenderObject(BuildContext context, RenderSlowLayout renderObject) => renderObject.name = name;
}

class RenderSlowLayout extends RenderProxyBox {
  RenderSlowLayout({RenderBox? child, required this.name}) : super(child);

  String name;

  @override
  void performLayout() {
    super.performLayout();
    print('$runtimeType#$name simulates slow layout (timeRemain: $timeRemain -> ${timeRemain - 1})');
    timeRemain--;
  }
}
```

outputs

```shell
frame #1
_FrameSeparateWidgetState#0 build: time is ok, give normal child
RenderSlowLayout#0 simulates slow layout (timeRemain: 3 -> 2)
_FrameSeparateWidgetState#1 build: time is ok, give normal child
SlowBuildWidget#1 simulates slow build (timeRemain: 2 -> 1)
_FrameSeparateWidgetState#2 build: time is ok, give normal child
RenderSlowLayout#2 simulates slow layout (timeRemain: 1 -> 0)
_FrameSeparateWidgetState#3 build: time is up, give dummy
_FrameSeparateWidgetState#4 build: time is up, give dummy
frame #2
_FrameSeparateWidgetState#3 build: time is ok, give normal child
SlowBuildWidget#3 simulates slow build (timeRemain: 3 -> 2)
_FrameSeparateWidgetState#4 build: time is ok, give normal child
RenderSlowLayout#4 simulates slow layout (timeRemain: 2 -> 1)
frame #3
```

</details>

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T14:35:35Z" retrieveTime="2022-10-15T21:31:00.632251">

@Nayuta403 If you are interested, I can try to make it a full library. Given that it is based on keframe's idea (hack widget build), but at the same time it is quite different from the existing implementation (do not use addPostFrameCallback and use the LayoutBuilder hack), I am not sure whether I should make a PR to keframe, or I should create a separate lib by myself (and mention keframe)?

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T16:22:11Z" retrieveTime="2022-10-15T21:31:00.632251">

@fzyzcjy  Hi man, you are very thoughtful and full of passion, thank you for your thoughts. Recently I have been busy with work.I want to first communicate with you about Keframe idea and then follow up your discussion.

>As can be seen in the code example below, the key point is a LayoutBuilder wrapped as parent of FrameSeparateWidget.  By doing so, we ensure that the build and layout phase of widgets prior to the current widget has already been done.

👍 👍   Your idea is great, we can hit the timer at the beginning of a frame and it seems to calculate the `timeRemian`. If you don't mind, I think you can create a branch/PR in KeFrame for discussion (I've given you a Write access) because there's some basic mechanics in there and a ready-made example in there.

> In addition, it always lag by one frame, because it uses setState in a addPostFrameCallback to update its widget.

I think this will not happen, because KeFrame calls `addPostTimeCallBack` during initState (i.e.https://github.com/flutter/flutter/blob/5816d20b86b95205c40921fa91ee3434b9c97ac6/packages/flutter/lib/src/scheduler/binding.dart#L1197-L1201) and _postFrameCallbacks call after `_persistentCallbacks` is finished (i.e.
https://github.com/flutter/flutter/blob/5816d20b86b95205c40921fa91ee3434b9c97ac6/packages/flutter/lib/src/scheduler/binding.dart#L1203-L1210), They're both in the `handleDrawFrame` method, so I think they're still in the same frame.

Ps: I actually think Fiber and Keframe will end up with similar results, but Keframe will work within the existing framework and won't require a lot of changes to the framework and engine. I think we can contribute it to the flutter after we've optimized it, like nested in a ListView or a Column or something, and open it with flags, like a RepaintBoundary.







 




</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T23:12:10Z" retrieveTime="2022-10-15T21:31:00.632251">

@Nayuta403 You are welcome!

> we can hit the timer at the beginning of a frame and it seems to calculate the timeRemian

Yes, just like my "layout" demo, which I recorded when the frame begins.

> In addition, it always lag by one frame, ... I think this will not happen

Well yes the function call is in the same frame; but indeed, if I understand correctly, the *build* will lag one frame. Consider the simplest example, where we are building a new widget tree (thus initState) with a child. Then, in frame 1, FrameSeparateWidget has initState and build called. But it is only at the post-frame callback phase that FrameSeparateWidget.result is filled with the real child. So it is only at frame 2 that FrameSeparateWidget really renders the child onto the screen.

> Ps: I actually think Fiber and Keframe will end up with similar results, but Keframe will work within the existing framework and won't require a lot of changes to the framework and engine. I think we can contribute it to the flutter after we've optimized it, like nested in a ListView or a Column or something, and open it with flags, like a RepaintBoundary.

That looks interesting, and I love to contribute to Flutter :) But I am worried whether Flutter will accept such widgets that can live in thirdparty packages. On the contrary, if we need to modify the framework and it has to be integrated with the framework, then surely we need to put it into flutter framework.

> create a branch/PR in KeFrame for discussion (I've given you a Write access) 

Thanks for your invitation (I see it). However, I realize keframe is under `LianJia`, a commercial company. It is not a person (e.g. you), a nonprofit organization (e.g. the flutter organization, the llvm org, the mobx org), a company known to have a ton of open source contributions (e.g. google), or something like that. So I am very sorry I cannot join it. But anyway, all my work will be open-sourced, and under license like MIT, so everyone can use it!

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-17T23:33:32Z" retrieveTime="2022-10-15T21:31:00.632251">

@Nayuta403 A bit more explanation: Why we do not need to worry about "the child subtree build&layout for a FrameSeparateWidget is so long that it makes everything slow"?

Because if that is the case, we can wrap several FrameSeparateWidget in the heavy parts of that subtree. Then, because each (new version I proposed yesterday) FrameSeparateWidget builds normally if not timeout, it will behave normally if time is ok; on the contrary, as long as time is up, subtree will pause to build. By doing this, we can ensure every FrameSeparateWidget takes moderate time length (say, 1ms), and there is no such case as one FrameSeparateWidget taking (e.g.) 100ms so everything is jank.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-18T04:11:00Z" retrieveTime="2022-10-15T21:31:00.632251">

**Update:** Some experiments here using the new implementation ([proposed here](https://github.com/flutter/flutter/issues/101227#issuecomment-1250056634)).

https://github.com/fzyzcjy/flutter_smooth

Btw I find that performance boost varies a lot when considering different experiments.

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-18T16:05:22Z" retrieveTime="2022-10-15T21:31:00.632251">

> But anyway, all my work will be open-sourced, and under license like MIT, so everyone can use it!

Yes, I was negligent. `Lianjia` is the company I used to work for. Just because this project is completed by me and has a certain number of users, I am still maintaining it personally. You are absolutely right, I also wish we had some open-sourced work available to everyone.  We can work on your project https://github.com/fzyzcjy/flutter_smooth

> A bit more explanation: Why we do not need to worry about "the child subtree build&layout for a FrameSeparateWidget is so long that it makes everything slow"?

Yes, I can understand that. For the subtree to time out, we can delay the build again by nesting the FrameSeparateWidget, which I've used before. I think from this point of view, all widget builds are interruptible, this Fiber-like mechanism.  I have a crazy idea that if we add a `placholder` property to all widget(Not all, we can add this property to some base class), we will build the `placholder` if the frame `timeRemain` time is 0. Then the jank will never happen ! HHHHH

> Update: Some experiments here using the new implementation.

I like your new implementation, which seems to have solved the problem we mentioned earlier by laying out as many widgets as possible in each frame. I think there may be some details that need to be added ：
* Whether other lifecycle states should be considered for `_SmoothState`, such as `didUpdateWidget` or `onDispose`. For example, I encountered an error in keframe when setState was called from outside because `result` was cached in State. If the `widget.child` is changed externally so that it does not work (It doesn't look like it's going to happen because you're using widget.child directly in build, but I think you might need to think about it when using State, I can add a https://github.com/LianjiaTech/keframe/blob/master/example/lib/page/complex_list_example.dart in your example)
* In your example, the height of the item is 24. But for the list, many times we don't know the width and height at code time, and jitter will occur when the placeholder and the actual list are not the same width and height.(because placeholder becomes item, Causing sibling layout changes). like this [example](https://github.com/LianjiaTech/keframe/blob/master/example/lib/page/opt/list_opt_example2.dart) in keframe. I did this by using `SizeCacheWidget` to cache the width and height of the item and force it to the placeholder so that it would not shake the second time the item was displayed. (You can't avoid it the first time, because the Item doesn't have a layout.) Do you have any other ideas?


> On the contrary, if we need to modify the framework and it has to be integrated with the framework, then surely we need to put it into flutter framework.

Yes, I think if we do it well enough, we can communicate with the Flutter Team and submit it to the Flutter Framework.  I communicated with @dnfield  a long time ago and he was also interested in it. [discord](https://discord.com/channels/608014603317936148/613398126367211520/977268943238602782)
 If we want to commit to Flutter Framework , what is the value of `kTimeThreshold`? Since we are only counting the build/layout time now, using 16.7 doesn't seem particularly appropriate, and for 120HZ devices, this value should be 16.7/2 ms

How do you think about it?







</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-18T23:03:56Z" retrieveTime="2022-10-15T21:31:00.632251">

> Yes, I was negligent. Lianjia is the company I used to work for. Just because this project is completed by me and has a certain number of users, I am still maintaining it personally. You are absolutely right, I also wish we had some open-sourced work available to everyone. We can work on your project https://github.com/fzyzcjy/flutter_smooth

Sure! Looking forward to collaborations :)

>  I have a crazy idea that if we add a placholder property to all widget(Not all, we can add this property to some base class), we will build the placholder if the frame timeRemain time is 0. Then the jank will never happen ! HHHHH

Haha that is really a crazy idea! The problem is overhead will be very big though :)

> Whether other lifecycle states should be considered for _SmoothState, such as...

Agree! At least we should add a test in our code, asserting its correctness

> I did this by using SizeCacheWidget

I think that is a pretty smart idea, and has not found other solutions yet. If you approve I will add things similar to that into the codebase. The idea will be the same, while implementation will differ slightly (e.g. use a InheritedWidget + StatefulWidget + controller).

> Yes, I think if we do it well enough, we can communicate with the Flutter Team and submit it to the Flutter Framework. I communicated with @dnfield a long time ago and he was also interested in it. [discord](https://discord.com/channels/608014603317936148/613398126367211520/977268943238602782)

Totally agree. (Btw I have searched through the history a few days ago: https://github.com/flutter/flutter/issues/101227#issuecomment-1249961627)

> If we want to commit to Flutter Framework , what is the value of kTimeThreshold? Since we are only counting the build/layout time now, using 16.7 doesn't seem particularly appropriate, and for 120HZ devices, this value should be 16.7/2 ms

The 120hz should be simple since we can detect what frequency we are under.

The problem is "we are only counting the build/layout time now". 

Btw, I realized that, for a scrolling list, the "finalizing" phase also takes time. Let alone the paint/compositing phase we all have known.

They (paint/compositing/finalizing) each take a little of time, but when accumulated, it is non-neglectible for that 16ms.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-18T23:09:40Z" retrieveTime="2022-10-15T21:31:00.632251">

Btw, recent ideas:

* I am considering halting the `paint` phase as well: Maybe we can directly reuse the old Layer, so we can get the same UI and at the same time do not call paint on subtree. This is just very naive idea and I will make an experiment later.
* "for a scrolling list, the "finalizing" phase also takes time" - Maybe we can hack ListView itself, and control when it disposes its widgets.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-20T13:46:34Z" retrieveTime="2022-10-15T21:31:00.632251">

### New idea: Preemption

#### Advantages

It can nearly achieve my goal: 60fps, no matter how heavy your build/layout are. Without limitations of other approaches, such as the ones in flutter_smooth, or the ones in "layout" proposal where the widget subtree has to allow their build/layout not called in some frames.

It also *has zero overhead about re-layouting*, i.e. it will *never* need to pay any extra cost to layout, compared to the widget/layout based approaches. It also solves the problem of "how to suspend a layout". I can explain more advantages and comparisons if needed.

Compared with the "dual isolate" proposal above, that one seems very hard to implement as it requires threads or coroutines, but this proposal is not. In addition, this proposal eliminate the second "sidecar" isolate, and everything is in main isolate, so we can run any code with all data in main isolate memory visible.

#### Details

Continue and modified from https://github.com/flutter/flutter/issues/101227#issuecomment-1249005541 (the "dual isolates" idea, but without the need of adding new threads (very troublesome to do syncing), or c++ coroutines (troublesome when c++ wants to call dart callback).

Notice that, the c++ code, main isolate, and sidecar isolate all run on "ui thread". No new threads, no coroutines, etc. So this time, the diagram draws nothing but very normal function calls.

Description of the figure:

* vsync comes.
* As normal, C++ calls Dart's drawFrame.
* Suppose Dart has 3 widgets to build/layout. It build/layout the 1st, then 2nd.
* Then it realizes time has up (say, 15ms has come), when `layout()` the 2nd widget. Then it calls `preemptRaster()` (a dart function).
* In `preemptRaster`, we firstly call `preemptModifyLayerTree` to modify the layer tree a bit, like CircularProgressIndicator or the scrolling ListView wrapper widget case, described in "dual isolate" proposal above. For simplicity, imagine this `preemptModifyLayerTree` is implemented via very low level API, such as `containerLayer.offset = Offset(10,20)`.
* In `preemptRaster`, we then call a probably modified version of FlutterView.render. In other words, we provide layer tree to C++ code, and c++ code provide it to raster thread. *Notice what layer tree we provide here*: Because `preemptRaster` is called within a `layout()`, the `paint` phase has not started, so the layer tree is completely old (instead of mixed). ThusIn addition, `preemptModifyLayerTree` will modify the layer tree a bit. That's all. We will send this to raster.
* Raster thread renders that layer tree as usual, so we see beautiful things on screen. 
* UI thread C++/Dart goes on, because `preemptRaster` function returns. The Dart code will continue from where `preemptRaster` is called (you know, just very plain function calls; but this solves the "how to suspend a layout call" implicitly indeed). In Dart's view, it thinks it is still the 1st frame. Let's say it continues layouting the 2nd widget. Then 3rd widget. Then paint, flush compositing bits, semantics, etc.
* Then finally, as a normal pipeline stage, dart provides the new layer tree and let c++ to throw it to the raster thread.
* Raster thread renders it to screen in the background.
* Then, just like what will be done normally in frame 1, call post frame callbacks, c++ calls dart for some callbacks, etc.
* Now ui thread is idle. When next vsync comes, the same loop will go.

---


![UML时序图 (2)](https://user-images.githubusercontent.com/5236035/191271636-f4b8dc2d-8b35-42f5-87b4-42851eb5ef85.png)



</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-20T13:47:17Z" retrieveTime="2022-10-15T21:31:00.632251">

>  I think that is a pretty smart idea, and has not found other solutions yet. If you approve I will add things similar to that into the codebase. The idea will be the same, while implementation will differ slightly (e.g. use a InheritedWidget + StatefulWidget + controller).

Yeah, I think the code willn't be much different, or I can directly PR to your repo? This jitter usually occurs in ListView, which needs to be nested with SizeCacheWidget in KeFrame, and LayoutInfoNotification is emitted in FrameSpeWidget. So the user has to specify SizeCacheWidget if they want to user ListView.  if it's in Flutter framework, we can add it directly, or do you have other ideas?

>  The 120hz should be simple since we can detect what frequency we are under.

Yes, we can get it directly from the engine, but I have to see how to get it in the framework. It may be necessary to add an API

>  "for a scrolling list, the "finalizing" phase also takes time" - Maybe we can hack ListView itself, and control when it disposes its widgets.

Yes, I think we can ignore this factor for now as I understand it is not particularly time consuming. Or we can directly change the "finalizing" timing of the ListView.



> I am considering halting the paint phase as well: Maybe we can directly reuse the old Layer, so we can get the same UI and at the same time do not call paint on subtree. This is just very naive idea and I will make an experiment later.

I agree with that, I think you just need to nest `RepaintBoundary` on the subtree, right? Just like ListView item, avoid subtree paint causing pain in other widgets.


@fzyzcjy 

I got a bad cold yesterday, so I was late in answering the message


</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-20T13:48:45Z" retrieveTime="2022-10-15T21:31:00.632251">

@dnfield @Nayuta403 @JsouLiang (and other experts) I have made a "preemption" proposal, which is like a easy-to-implement version of "dual isolate". Looking forward to any feedbacks! I am going to implement a prototype tomorrow :)

---

Same thing in discord: https://discord.com/channels/608014603317936148/608021234516754444/1021783497112821861

There are some discussions going on there as well. For completeness, a reader of this github thread may need to go to this link and view comments there.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-20T13:53:17Z" retrieveTime="2022-10-15T21:31:00.632251">

@Nayuta403 

> or I can directly PR to your repo?

Sure! But I am hesitate whether going on flutter_smooth now, as the "preemption" proposal seems quite appealing and addresses many problems of flutter_smooth, the layout proposal, and the keframe.

Could you please have a look at "preemption" proposal :) I want to implement a prototype tomorrow (UTC+8 timezone).

> This jitter usually occurs in ListView, which needs to be nested with SizeCacheWidget in KeFrame, and LayoutInfoNotification is emitted in FrameSpeWidget. So the user has to specify SizeCacheWidget if they want to user ListView. if it's in Flutter framework, we can add it directly, or do you have other ideas?

That LGTM. Indeed I will do something like: The `SizeCacheWidget` (I may call it `SmoothParent`) has some inherited widget to provide a controller to its child subtree. Then child can save anything they want to that controller. Anyway, those are simple things, and I can also do it if you like (just need e.g. 15 minutes).

> Yes, we can get it directly from the engine, but I have to see how to get it in the framework. It may be necessary to add an API

I remembered I did that via calling java/swift. Anyway this is minor problem :)

> I agree with that, I think you just need to nest RepaintBoundary on the subtree, right? Just like ListView item, avoid subtree paint causing pain in other widgets.

Yes, but I hope not too many RepaintBoundary in the meanwhile. IIRC during some testing they add overheads. Btw the "preemption" proposal does not have this problem.

> I got a bad cold yesterday, so I was late in answering the message

Sorry to hear that, and hope you are getting well!

</DiscussionComment>

<DiscussionComment author="Nayuta403" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-20T14:27:41Z" retrieveTime="2022-10-15T21:31:00.632251">

>  Anyway, those are simple things, and I can also do it if you like (just need e.g. 15 minutes).

Haha OK, you do it 👍🏻  If I do I think it will probably take more than 15 minutes to communicate. hhhh


>  Could you please have a look at "preemption" proposal :) I want to implement a prototype tomorrow (UTC+8 timezone).

I wonder how this Frame1 is generated, now there are only two widgets with build/layout and neither of them have paint/comp etc. If you use the LayerTree from the previous frame that It looks the same as it does now. (A jank happened) 
Am I getting it wrong?  I'm looking forward to seeing your prototype : )

![image](https://user-images.githubusercontent.com/40540394/191283147-dc43f524-fa0d-4681-8273-f23356c39860.png)










</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-20T14:34:30Z" retrieveTime="2022-10-15T21:31:00.632251">

> If I do I think it will probably take more than 15 minutes to communicate. hhhh

Haha I think so!

> I wonder how this Frame1 is generated, now there are only two widgets with build/layout and neither of them have paint/comp etc

Well I should say, this diagram happens *after* we have rendered a lot of frames. So the layer tree is already there, just *without* the several newly added/modified widgets.

> If you use the LayerTree from the previous frame that It looks the same as it does now. (A jank happened)
Am I getting it wrong?

No, I call `preemptModifyLayerTree`. That one handles animations, e.g. CircularProgressIndicator, or ListView scrolling, or opacity changing animation. For simplest example, for opacity, it may update a OpacityLayer.opacity from 0.1 to 0.2 etc.

> I'm looking forward to seeing your prototype : )

Thanks :)

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-21T01:05:56Z" retrieveTime="2022-10-15T21:31:00.632251">

Design proposal: https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit?usp=sharing

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-21T13:15:53Z" retrieveTime="2022-10-15T21:31:00.632251">

For readers of GitHub and not yet read Discord: Some discussions happen in Discord as well, see - https://discord.com/channels/608014603317936148/608021234516754444/1021783497112821861

As well as the sub-discussion in discord: https://discord.com/channels/608014603317936148/1021987751710699632

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-22T14:46:52Z" retrieveTime="2022-10-15T21:31:00.632251">

Update: minimalist API (one widget for everything) + a prototype about framework layer.

Now, developers will only need to insert `PreemptBuilder(builder: (context, child) => whatever_you_like, child: also_free_to_choose)` widget, and that's all. Arbitrary builder, arbitrary child subtree, and smooth 60fps will be there for the builder. The google doc is updated to discuss this - mainly in (1) "usage examples" (2) "From preemptModifyLayerTree to PreemptBuilder" in "detailed design".

Code prototype:

<details>

```dart
// ignore_for_file: avoid_print, prefer_const_constructors, invalid_use_of_protected_member

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

final secondTreePack = SecondTreePack();

// since prototype, only one [RenderAdapterInSecondTree], so do like this
final mainSubTreeLayerHandle = LayerHandle(OffsetLayer());

void main() {
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  secondTreePack; // touch it
  mainSubTreeLayerHandle; // touch it
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    print('$runtimeType.build ($buildCount)');

    if (buildCount < 5) {
      Future.delayed(Duration(seconds: 1), () {
        print('$runtimeType.setState after a second');
        setState(() {});
      });
    }

    return MaterialApp(
      home: Scaffold(
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Text('A$buildCount', style: TextStyle(fontSize: 30)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.orange[(buildCount % 8 + 1) * 100]!,
              width: 10,
            ),
          ),
          width: 300,
          height: 300,
          // hack: [AdapterInMainTreeWidget] does not respect "offset" in paint
          // now, so we add a RepaintBoundary to let offset==0
          // hack: [AdapterInMainTreeWidget] does not respect "offset" in paint
          // now, so we add a RepaintBoundary to let offset==0
          child: RepaintBoundary(
            child: AdapterInMainTreeWidget(
              parentBuildCount: buildCount,
              // child: DrawCircleWidget(parentBuildCount: buildCount),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.pink[(buildCount % 8 + 1) * 100],
                ),
              ),
            ),
          ),
        ),
        Text('B$buildCount', style: TextStyle(fontSize: 30)),
        WindowRenderWhenLayoutWidget(parentBuildCount: buildCount),
        Text('C$buildCount', style: TextStyle(fontSize: 30)),
      ],
    );
  }
}

class WindowRenderWhenLayoutWidget extends SingleChildRenderObjectWidget {
  final int parentBuildCount;

  const WindowRenderWhenLayoutWidget({
    super.key,
    required this.parentBuildCount,
    super.child,
  });

  @override
  WindowRenderWhenLayoutRender createRenderObject(BuildContext context) =>
      WindowRenderWhenLayoutRender(
        parentBuildCount: parentBuildCount,
      );

  @override
  void updateRenderObject(
      BuildContext context, WindowRenderWhenLayoutRender renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class WindowRenderWhenLayoutRender extends RenderProxyBox {
  WindowRenderWhenLayoutRender({
    required int parentBuildCount,
    RenderBox? child,
  })  : _parentBuildCount = parentBuildCount,
        super(child);

  int get parentBuildCount => _parentBuildCount;
  int _parentBuildCount;

  set parentBuildCount(int value) {
    if (_parentBuildCount == value) return;
    _parentBuildCount = value;
    print('$runtimeType markNeedsLayout because parentBuildCount changes');
    markNeedsLayout();
  }

  @override
  void performLayout() {
    // unconditionally call this, as an experiment
    pseudoPreemptRender();

    super.performLayout();
  }

  void pseudoPreemptRender() {
    print('$runtimeType pseudoPreemptRender start');

    // ref: https://github.com/fzyzcjy/yplusplus/issues/5780#issuecomment-1254562485
    // ref: RenderView.compositeFrame

    final builder = SceneBuilder();

    // final recorder = PictureRecorder();
    // final canvas = Canvas(recorder);
    // final rect = Rect.fromLTWH(0, 0, 500, 500);
    // canvas.drawRect(Rect.fromLTWH(100, 100, 50, 50.0 * parentBuildCount),
    //     Paint()..color = Colors.green);
    // final pictureLayer = PictureLayer(rect);
    // pictureLayer.picture = recorder.endRecording();
    // final rootLayer = OffsetLayer();
    // rootLayer.append(pictureLayer);
    // final scene = rootLayer.buildScene(builder);

    final binding = WidgetsFlutterBinding.ensureInitialized();

    preemptModifyLayerTree(binding);

    // why this layer? from RenderView.compositeFrame
    final scene = binding.renderView.layer!.buildScene(builder);

    print('call window.render');
    window.render(scene);

    scene.dispose();

    print('$runtimeType pseudoPreemptRender end');
  }

  void preemptModifyLayerTree(WidgetsBinding binding) {
    // hack, just want to prove we can change something (preemptModifyLayerTree)
    // inside the preemptRender
    final rootLayer = binding.renderView.layer! as TransformLayer;
    rootLayer.transform =
        rootLayer.transform!.multiplied(Matrix4.translationValues(0, 50, 0));
    print('preemptModifyLayerTree rootLayer=$rootLayer (after)');

    refreshSecondTree();
  }

  void refreshSecondTree() {
    print('$runtimeType refreshSecondTree start');
    secondTreePack.innerStatefulBuilderSetState(() {});

    // NOTE reference: WidgetsBinding.drawFrame & RendererBinding.drawFrame
    // https://github.com/fzyzcjy/yplusplus/issues/5778#issuecomment-1254490708
    secondTreePack.buildOwner.buildScope(secondTreePack.element);
    secondTreePack.pipelineOwner.flushLayout();
    secondTreePack.pipelineOwner.flushCompositingBits();
    secondTreePack.pipelineOwner.flushPaint();
    // renderView.compositeFrame(); // this sends the bits to the GPU
    // pipelineOwner.flushSemantics(); // this also sends the semantics to the OS.
    secondTreePack.buildOwner.finalizeTree();

    print('$runtimeType refreshSecondTree end');
  }
}

class AdapterInMainTreeWidget extends SingleChildRenderObjectWidget {
  final int parentBuildCount;

  const AdapterInMainTreeWidget({
    super.key,
    required this.parentBuildCount,
    super.child,
  });

  @override
  RenderAdapterInMainTree createRenderObject(BuildContext context) =>
      RenderAdapterInMainTree(parentBuildCount: parentBuildCount);

  @override
  void updateRenderObject(
      BuildContext context, RenderAdapterInMainTree renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class RenderAdapterInMainTree extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderAdapterInMainTree({
    required int parentBuildCount,
    // RenderBox? child,
  }) : _parentBuildCount = parentBuildCount;

  // super(child);

  int get parentBuildCount => _parentBuildCount;
  int _parentBuildCount;

  set parentBuildCount(int value) {
    if (_parentBuildCount == value) return;
    _parentBuildCount = value;
    print('$runtimeType markNeedsLayout because parentBuildCount changes');
    markNeedsLayout();
  }

  // should not be singleton, but we are prototyping so only one such guy
  static RenderAdapterInMainTree? instance;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    assert(instance == null);
    instance = this;
  }

  @override
  void detach() {
    assert(instance == this);
    instance == null;
    super.detach();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('$runtimeType.layout called');
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    print('$runtimeType.performLayout start');

    // NOTE
    secondTreePack.rootView.configuration =
        SecondTreeRootViewConfiguration(size: constraints.biggest);

    print('$runtimeType.performLayout child.layout start');
    child!.layout(constraints);
    print('$runtimeType.performLayout child.layout end');

    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  // static final staticPseudoRootLayerHandle = () {
  //   final recorder = PictureRecorder();
  //   final canvas = Canvas(recorder);
  //   final rect = Rect.fromLTWH(0, 0, 200, 200);
  //   canvas.drawRect(
  //       Rect.fromLTWH(0, 0, 50, 100), Paint()..color = Colors.green);
  //   final pictureLayer = PictureLayer(rect);
  //   pictureLayer.picture = recorder.endRecording();
  //   final wrapperLayer = OffsetLayer();
  //   wrapperLayer.append(pictureLayer);
  //
  //   final pseudoRootLayer = TransformLayer(transform: Matrix4.identity());
  //   pseudoRootLayer.append(wrapperLayer);
  //
  //   pseudoRootLayer.attach(secondTreePack.rootView);
  //
  //   return LayerHandle(pseudoRootLayer);
  // }();

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(offset == Offset.zero,
        '$runtimeType prototype has not deal with offset yet');

    print('$runtimeType.paint called');

    // super.paint(context, offset);
    // return;

    // context.canvas.drawRect(Rect.fromLTWH(0, 0, 50, 50.0 * parentBuildCount),
    //     Paint()..color = Colors.green);
    // return;

    // context.pushLayer(
    //   OpacityLayer(alpha: 100),
    //   (context, offset) {
    //     context.canvas.drawRect(
    //         Rect.fromLTWH(0, 0, 50, 50.0 * parentBuildCount),
    //         Paint()..color = Colors.green);
    //   },
    //   offset,
    // );
    // return;

    // context.addLayer(PerformanceOverlayLayer(
    //   overlayRect: Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
    //   optionsMask: 1 <<
    //           PerformanceOverlayOption.displayRasterizerStatistics.index |
    //       1 << PerformanceOverlayOption.visualizeRasterizerStatistics.index |
    //       1 << PerformanceOverlayOption.displayEngineStatistics.index |
    //       1 << PerformanceOverlayOption.visualizeEngineStatistics.index,
    //   rasterizerThreshold: 0,
    //   checkerboardRasterCacheImages: true,
    //   checkerboardOffscreenLayers: true,
    // ));
    // return;

    // {
    //   final recorder = PictureRecorder();
    //   final canvas = Canvas(recorder);
    //   final rect = Rect.fromLTWH(0, 0, 200, 200);
    //   canvas.drawRect(Rect.fromLTWH(0, 0, 50, 50.0 * parentBuildCount),
    //       Paint()..color = Colors.green);
    //   final pictureLayer = PictureLayer(rect);
    //   pictureLayer.picture = recorder.endRecording();
    //   final wrapperLayer = OffsetLayer();
    //   wrapperLayer.append(pictureLayer);
    //
    //   // NOTE addLayer vs pushLayer
    //   context.addLayer(wrapperLayer);
    //
    //   print('pictureLayer.attached=${pictureLayer.attached} '
    //       'wrapperLayer.attached=${wrapperLayer.attached}');
    //
    //   return;
    // }

    // {
    //   if (staticPseudoRootLayerHandle.layer!.attached) {
    //     print('pseudoRootLayer.detach');
    //     staticPseudoRootLayerHandle.layer!.detach();
    //   }
    //
    //   print('before addLayer staticPseudoRootLayer=${staticPseudoRootLayerHandle.layer!.toStringDeep()}');
    //
    //   context.addLayer(staticPseudoRootLayerHandle.layer!);
    //
    //   print('after addLayer staticPseudoRootLayer=${staticPseudoRootLayerHandle.layer!.toStringDeep()}');
    //
    //   return;
    // }

    // ref: RenderOpacity

    // TODO this makes "second tree root layer" be *removed* from its original
    //      parent. shall we move it back later? o/w can be slow!
    final secondTreeRootLayer = secondTreePack.rootView.layer!;

    // print(
    //     'just start secondTreeRootLayer=${secondTreeRootLayer.toStringDeep()}');

    // HACK!!!
    if (secondTreeRootLayer.attached) {
      print('$runtimeType.paint detach the secondTreeRootLayer');
      // TODO attach again later?
      secondTreeRootLayer.detach();
    }

    // print(
    //     'before addLayer secondTreeRootLayer=${secondTreeRootLayer.toStringDeep()}');

    print('$runtimeType.paint addLayer');
    // NOTE addLayer, not pushLayer!!!
    context.addLayer(secondTreeRootLayer);
    // context.pushLayer(secondTreeRootLayer, (context, offset) {}, offset);

    print('secondTreeRootLayer.attached=${secondTreeRootLayer.attached}');
    print(
        'after addLayer secondTreeRootLayer=${secondTreeRootLayer.toStringDeep()}');

    // ================== paint those child in main tree ===================

    // NOTE do *not* have any relation w/ self's PaintingContext, as we will not paint there
    {
      // ref: [PaintingContext.pushLayer]
      if (mainSubTreeLayerHandle.layer!.hasChildren) {
        mainSubTreeLayerHandle.layer!.removeAllChildren();
      }
      final childContext = PaintingContext(
          mainSubTreeLayerHandle.layer!, context.estimatedBounds);
      child!.paint(childContext, Offset.zero);
      childContext.stopRecordingIfNeeded();
    }

    // =====================================================================
  }

// TODO handle layout!
}

class AdapterInSecondTreeWidget extends SingleChildRenderObjectWidget {
  final int parentBuildCount;

  const AdapterInSecondTreeWidget({
    super.key,
    required this.parentBuildCount,
    super.child,
  });

  @override
  RenderAdapterInSecondTree createRenderObject(BuildContext context) =>
      RenderAdapterInSecondTree(parentBuildCount: parentBuildCount);

  @override
  void updateRenderObject(
      BuildContext context, RenderAdapterInSecondTree renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class RenderAdapterInSecondTree extends RenderBox {
  RenderAdapterInSecondTree({
    required int parentBuildCount,
  }) : _parentBuildCount = parentBuildCount;

  int get parentBuildCount => _parentBuildCount;
  int _parentBuildCount;

  set parentBuildCount(int value) {
    if (_parentBuildCount == value) return;
    _parentBuildCount = value;
    print('$runtimeType markNeedsLayout because parentBuildCount changes');
    markNeedsLayout();
  }

  // should not be singleton, but we are prototyping so only one such guy
  static RenderAdapterInSecondTree? instance;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    assert(instance == null);
    instance = this;
  }

  @override
  void detach() {
    assert(instance == this);
    instance == null;
    super.detach();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('$runtimeType.layout called');
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    print('$runtimeType.performLayout called');
    size = constraints.biggest;
  }

  // TODO correct?
  @override
  bool get alwaysNeedsCompositing => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    print('$runtimeType paint');
    context.addLayer(mainSubTreeLayerHandle.layer!);
  }
}

class SecondTreePack {
  late final PipelineOwner pipelineOwner;
  late final SecondTreeRootView rootView;
  late final BuildOwner buildOwner;
  late final RenderObjectToWidgetElement<RenderBox> element;

  var innerStatefulBuilderBuildCount = 0;
  late StateSetter innerStatefulBuilderSetState;

  SecondTreePack() {
    pipelineOwner = PipelineOwner();
    rootView = pipelineOwner.rootNode = SecondTreeRootView(
      configuration: SecondTreeRootViewConfiguration(size: Size.zero),
    );
    buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () =>
          print('second tree BuildOwner.onBuildScheduled called'),
    );

    rootView.prepareInitialFrame();

    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($innerStatefulBuilderBuildCount)');

      innerStatefulBuilderSetState = setState;
      innerStatefulBuilderBuildCount++;

      return Container(
        width: 50 * innerStatefulBuilderBuildCount.toDouble(),
        height: 100,
        color: Colors.blue[(innerStatefulBuilderBuildCount * 100) % 800 + 100],
        child: AdapterInSecondTreeWidget(
          parentBuildCount: innerStatefulBuilderBuildCount,
        ),
      );
    });

    element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);
  }
}

// ref: [ViewConfiguration]
class SecondTreeRootViewConfiguration {
  const SecondTreeRootViewConfiguration({
    required this.size,
  });

  final Size size;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ViewConfiguration && other.size == size;
  }

  @override
  int get hashCode => size.hashCode;

  @override
  String toString() => '$size';
}

class SecondTreeRootView extends RenderObject
    with RenderObjectWithChildMixin<RenderBox> {
  SecondTreeRootView({
    RenderBox? child,
    required SecondTreeRootViewConfiguration configuration,
  }) : _configuration = configuration {
    this.child = child;
  }

  // NOTE ref [RenderView.size]
  /// The current layout size of the view.
  Size get size => _size;
  Size _size = Size.zero;

  // NOTE ref [RenderView.configuration] which has size and some other things
  /// The constraints used for the root layout.
  SecondTreeRootViewConfiguration get configuration => _configuration;
  SecondTreeRootViewConfiguration _configuration;

  set configuration(SecondTreeRootViewConfiguration value) {
    if (configuration == value) {
      return;
    }
    print(
        '$runtimeType set configuration(i.e. size) $_configuration -> $value');
    _configuration = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    print(
        '$runtimeType performLayout configuration.size=${configuration.size}');

    _size = configuration.size;

    assert(child != null);
    child!.layout(BoxConstraints.tight(_size));
  }

  // ref RenderView
  @override
  void paint(PaintingContext context, Offset offset) {
    // NOTE we have to temporarily remove debugActiveLayout
    // b/c [SecondTreeRootView.paint] is called inside [preemptRender]
    // which is inside main tree's build/layout.
    // thus, if not set it to null we will see error
    // https://github.com/fzyzcjy/yplusplus/issues/5783#issuecomment-1254974511
    // In short, this is b/c [debugActiveLayout] is global variable instead
    // of per-tree variable
    final oldDebugActiveLayout = RenderObject.debugActiveLayout;
    RenderObject.debugActiveLayout = null;
    try {
      print('$runtimeType paint child start');
      context.paintChild(child!, offset);
      print('$runtimeType paint child end');
    } finally {
      RenderObject.debugActiveLayout = oldDebugActiveLayout;
    }
  }

  @override
  void debugAssertDoesMeetConstraints() => true;

  void prepareInitialFrame() {
    // ref: RenderView
    scheduleInitialLayout();
    scheduleInitialPaint(_updateMatricesAndCreateNewRootLayer());
  }

  // ref: RenderView
  TransformLayer _updateMatricesAndCreateNewRootLayer() {
    final rootLayer = TransformLayer(transform: Matrix4.identity());
    rootLayer.attach(this);
    return rootLayer;
  }

  // ref: RenderView
  @override
  bool get isRepaintBoundary => true;

  // ref: RenderView
  @override
  Rect get paintBounds => Offset.zero & size;

  // ref: RenderView
  @override
  void performResize() {
    assert(false);
  }

  // hack: just give non-sense value, this is prototype
  @override
  Rect get semanticBounds => paintBounds;
}

class DrawCircleWidget extends LeafRenderObjectWidget {
  final int parentBuildCount;

  const DrawCircleWidget({
    super.key,
    required this.parentBuildCount,
  });

  @override
  RenderDrawCircle createRenderObject(BuildContext context) => RenderDrawCircle(
        parentBuildCount: parentBuildCount,
      );

  @override
  void updateRenderObject(BuildContext context, RenderDrawCircle renderObject) {
    renderObject.parentBuildCount = parentBuildCount;
  }
}

class RenderDrawCircle extends RenderProxyBox {
  RenderDrawCircle({
    required int parentBuildCount,
    RenderBox? child,
  })  : _parentBuildCount = parentBuildCount,
        super(child);

  int get parentBuildCount => _parentBuildCount;
  int _parentBuildCount;

  set parentBuildCount(int value) {
    if (_parentBuildCount == value) return;
    _parentBuildCount = value;
    print('$runtimeType markNeedsLayout because parentBuildCount changes');
    markNeedsLayout();
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('$runtimeType performLayout');
    super.layout(constraints, parentUsesSize: parentUsesSize);
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    print('$runtimeType paint');
    context.canvas
        .drawCircle(Offset(50, 50), 100, Paint()..color = Colors.cyan);
  }
}
```

</details>

---

Next time I may only update progress in Discord, since there are already >hundred comments there - seems everyone is there instead of in github :)

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-23T13:28:16Z" retrieveTime="2022-10-15T21:31:00.632251">

### Prototype: Enter-new-heavy-page, smoothly even though it takes 0.5s to build/layout

Also posted in discord and google doc

#### Defects in the prototype compared to the future full implementation

* The page is so heavy that even paint without the time of build and layout causes a visible jank with PreemptBuilder; in real world should not be that slow (since in real world build/layout does not take 30 frames)
* Extra frame is driven by simple `DateTime.now` (instead of vsync), so it is not at its best performance
* Prototype code has not been fully clean up yet

#### Code

https://github.com/fzyzcjy/flutter/tree/experiment-forest and https://github.com/fzyzcjy/engine/tree/experiment-smooth

#### Downloadable app

[app-profile.apk.zip](https://github.com/flutter/flutter/files/9634000/app-profile.apk.zip)

#### Video

Firstly the slow (plain old) case, then the fast (using PreemptBuilder) case. The grey circle appears when I touch the screen (by android system recorder).

https://user-images.githubusercontent.com/5236035/191970843-a9c82a38-1276-4024-8a1b-c102c9b8e22f.mp4




</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-25T01:50:08Z" retrieveTime="2022-10-15T21:31:00.632251">

### Brief visual update: It runs at ~60fps, while widget build/layout needs ~500ms

X-Posted: https://discord.com/channels/608014603317936148/608021234516754444/1023410732336939129

Video description: (1) The slow (plain-old) case is repeated twice (2) Then the fast (using PreemptBuilder) case is done twice (3) Lastly a debug animation is shown (to be explained below).

How to verify it is 60fps: I personally use `ffmpeg -i $VIDEO -vsync 0 -frame_pts true -vf drawtext=fontfile=/usr/share/fonts/truetype/freefont/FreeMonoBold.ttf:fontsize=80:text='%{pts}':fontcolor=white@0.8:x=7:y=7 ~/temp/video_frames/output_%04d.jpg` to extract every frame of the video.

P.S. The last section in the video (debug animation) is used to verify the file transfer. If that part is seen janky, then it is probably a problem when transferring the video file etc, since that should definitely be 60FPS.

As usual, the code is at the GitHub branch mentioned above.


https://user-images.githubusercontent.com/5236035/192124851-19bae792-ad31-4ae3-8717-8a0821038d00.mp4



</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-26T10:27:09Z" retrieveTime="2022-10-15T21:31:00.632251">

Latest video (if you are interested :))

https://user-images.githubusercontent.com/5236035/192254354-e65a8bd2-9f49-4c5b-acdf-eda3932402f9.mp4

(This comment is also linked from https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit#, i.e. 
[Preemption for 60 FPS (PUBLICLY SHARED) (4).pdf](https://github.com/flutter/flutter/files/9646963/Preemption.for.60.FPS.PUBLICLY.SHARED.4.pdf))


</DiscussionComment>

<DiscussionComment author="moffatman" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-26T12:15:54Z" retrieveTime="2022-10-15T21:31:00.632251">

Is build progress occuring during animation here? Because the effect could be replicated by just delaying the complex content build for ~500 ms (animation duration). 

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-26T12:37:42Z" retrieveTime="2022-10-15T21:31:00.632251">

@moffatman

> Is build progress occuring during animation here

Not completely get the question... If the question is, whether animation happens when the complex widget is being built/layouted, the answer is yes.

> Because the effect could be replicated by just delaying the complex content build for ~500 ms (animation duration).

You need some extra preempt points, instead of a single `sleep(500ms)`. For example, this should work:

```
build() {
  for(var i=0;i<100;++i) {
    Actor.instance.maybePreemptRender();
    sleep(const Duration(milliseconds: 5));
  }
  return your widget;
}
```

Indeed, preempt points are auto injected via PreemptPoint, and (possibly done in the real PR) in every RenderObject.layout. So usually no need to manually write that.

By the way, your original modification does not work, because by default I do not expect a single widget.build to exceed 16ms. Anyway if that is the case just insert a few `maybePreemptRender`.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-09-30T23:01:48Z" retrieveTime="2022-10-15T21:31:00.632251">

Quick update (still WIP, just provide some progress): I am working on the gesture system. Jonah Williams has thought that, it was bad that my old proposal did not let the pointer data packet go through Flutter's gesture system. Now, the new method just calls the classical `gestureBinding.handlePointerEvent` to dispatch `PointerMoveEvent`s.

</DiscussionComment>

<DiscussionComment author="fzyzcjy" link="https://github.com/flutter/flutter/issues/101227" source="github" createTime="2022-10-12T14:04:46Z" retrieveTime="2022-10-15T21:31:00.632251">

### Quick update: ListView scrolling at 60FPS with heavy build/layout

Highlights:

* It is 60FPS <small>(check via splitting video into frames, and by my script to examine timeline tracing data; not checked this demo video though; you can find the script in my repo)</small>
* The list shifting is (roughly) uniform speed (up to error from OS pointer events) <small>(check via script to examine timeline tracing data; again script is in my repo)</small>
* The system uses `gestureBinding.handlePointerEvent` to dispatch `PointerMoveEvent`s

Experiment setup: Slow build/layout when new item comes in. Full code can be seen in https://github.com/fzyzcjy/flutter_smooth.

May still contain (a lot of) bugs, since it is still WIP :)

Video (firstly raw case, then use-flutter_smooth case):

https://user-images.githubusercontent.com/5236035/195363841-240fa44c-c471-412e-9c3d-3314cf6ed8ea.mp4

Sample screenshots from tracing and my script:

![image](https://user-images.githubusercontent.com/5236035/195364264-b84063a8-9a62-416c-8684-424dbc14ed4c.png)
![image](https://user-images.githubusercontent.com/5236035/195364393-6ee2fa8c-697e-4298-92e6-c4a7a6cc7dd3.png)


</DiscussionComment>