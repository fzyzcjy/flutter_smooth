# Summary

Many people have discussed and worked on the main problem that `flutter_smooth` aims to solve - the jank caused by slow build/layout. Here is a brief summary after I [digged into](https://github.com/flutter/flutter/issues/101227#issuecomment-1249961627) the history, for completeness, just like the "literature review" that everyone needs to do when writing a paper. This list may be incomplete. Feel free to create an issue if you find something is missing, or something needs to be added for deeper understanding of the topic.

## @fzyzcjy

Put myself first since I fail the most times :)

### Source

Mainly [this issue](https://github.com/flutter/flutter/issues/101227).

### Main idea

- ([link](https://github.com/flutter/flutter/issues/101227#issue-1190511582)) Directly migrate the Fiber from React (JavaScript) into Flutter - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1087243414) and [prototype](https://github.com/fzyzcjy/flutter_smooth_experiment_2022_april)) Hack the build and layout phase in [this prototype repo](https://github.com/fzyzcjy/flutter_smooth_experiment_2022_april) - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1247541808)) Let animation be in a new subtree, and run its layout/paint firstly, with other low-priority subtree pauseable - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1247625317) and [link](https://github.com/flutter/flutter/issues/101227#issuecomment-1247871402)) Based on the idea above, and allow children to be half-baked, and use `toPictureSync` to avoid problem of half-done children - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1247631508)) Use `yield` to make it suspendable, like Redux Saga - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1247849735) and [prototype](https://github.com/flutter/flutter/issues/101227#issuecomment-1248894781)) Use a new RenderObject which early returns when timeout - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1249005541)) Dual isolates, using a second isolate to compute animation widgets - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1249961627)) Experiment to use stackful coroutine or thread mutex to implement it - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1250056634)) Enhance keframe by running as much as possible before deadline - failed
- ([link](https://github.com/flutter/flutter/issues/101227#issuecomment-1252379787)) The "preemption" proposal, which later becomes one of the main ideas of this package

## @Hixie, @dnfield, ...

... and @goderbauer, @chunhtai, @gspencergoog (who spoke in the discussions).

### Source

Some discussions starting from [here](https://discord.com/channels/608014603317936148/608021234516754444/930241489374683157) and ending [here](https://discord.com/channels/608014603317936148/608021234516754444/931276162058031145). Hixie is also said to have tried [an experiment](https://discord.com/channels/608014603317936148/613398126367211520/977090864813846548) (I have not found the details though).

### Main idea

Interruptible layout. "Do as much work as you can but yield after X ms, and resume when I call you back from where you left off" (quoted from [here](https://discord.com/channels/608014603317936148/608021234516754444/930882722849771590)).

## @gaaclarke

### Source

Messages near [here](https://discord.com/channels/608014603317936148/608021234516754444/1022292715221831680), when discussing my proposal.

### Main idea

Slowness of build/layout may be caused by memory locality which will be hard to fix.

## @Nayuta403 and Alibaba

### Source

A few sources:

* The blogs ([this](https://juejin.cn/post/6940134891606507534) and [this](https://juejin.cn/post/6979781997568884766)) from @Nayuta403.
* [This](https://juejin.cn/post/6888887439922987022) blog from Alibaba (also quoted by @Nayuta403 in the blogs above).
* Also having some discussions [here](https://discord.com/channels/608014603317936148/608014603317936150/977074969542553600) and [here](https://discord.com/channels/608014603317936148/613398126367211520/977109431408009317) among @Nayuta403 and Flutter team.

### Main idea

Separate frame. The heavy job is separated into multiple smaller jobs, and each frame only process one (by @Nayuta403) or a predetermined number (by Alibaba) of the jobs.

## React Fiber

### Source

N/A (It is an official release, not a discussion or experiment)

### Main idea

When the browser needs to do rendering work, JS suspends the current work to let the JavaScript thread be idle, and continue later.

## @xanahopper, ...

... and probably @Nayuta403, @JsouLiang, @wangying3426 since they seem to be the same team.

## Sources

* Discussions such as [this](https://github.com/flutter/flutter/issues/101227#issuecomment-1249137253) and a few after it.

### Main idea

* Use multiple isolates instead of one
* Use structure like React Fiber such as threaded tree, and convert a tree of widgets to a chain list, so that it can be suspended at any iteration of traversal (similar to React Fiber spirit).
