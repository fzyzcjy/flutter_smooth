# Scenarios

:::info

This section, which describes some typical scenarios, is copied from the design doc for completeness.

:::

* **A** [**test case**](https://github.com/flutter/flutter/blob/master/dev/benchmarks/macrobenchmarks/lib/src/list_text_layout.dart) **in the framework**, pointed out by @dnfield: [He said](https://github.com/flutter/flutter/issues/101227#issuecomment-1247641562), this ends up being janky because layout gets expensive for all that text (on a lower end phone it can easily take 20-30+ms just to layout all the text there, and the ListTile is a little deceptive because Material introduces expense - this is the kind of thing we want to figure out how to break up "automatically").
* **Bytedance’s apps**: Infra team reports that they see such janks (around [here](https://discord.com/channels/608014603317936148/608021234516754444/1021980287787352125)). In addition, the infra team (Nayuta403, JsouLiang, xanahopper, wangying3426, etc) seems to have interest in [my issue](https://github.com/flutter/flutter/issues/101227), [chatted a lot](https://discord.com/channels/608014603317936148/1021987751710699632) on Discord discussing it, and proposing [build-based methods](https://github.com/flutter/flutter/issues/101227#issuecomment-1249172293) as well as [thread-based methods](https://github.com/flutter/flutter/issues/110063) to solve build/layout slowness - this surely will not happen if it were not a problem for Bytedance.
* **All apps using** [**keframe**](https://pub.dev/packages/keframe): Keframe is a library to optimize such janks (with comparison below), with 93% popularity on pub.dev and 741 stars on GitHub. If there is no such jank, I guess the package will have no users.
* **Alibaba’s apps:** According to [a blog](https://developer.aliyun.com/article/783168) from Alibaba, and another similar [blog](https://juejin.cn/post/6921902712107991054) by UC (in Alibaba), they mentioned that, when scrolling ListViews, “the build and layout of a newly created item in ListView usually takes a long time, maybe more than ten milliseconds, even dozens of milliseconds”. And “especially the situation when needing to build multiple items in one frame, they are the main cause of jank”. (P.S. Their rasterization is said to be “... page B is complex, it takes 7-10ms to rasterize, and once in a while more than 10ms.)
* **Really slow devices**: There exist many slow, slower, and slower-than-slower devices in the world. Without this proposal, a Flutter app must be janky when running on devices beneath a certain computation power threshold; with the proposal, they will still be smooth, or at least such threshold is lowered by a magnitude.
* **Enter-page transition**: Every app needs to enter pages. It is almost inevitable that the page contains complex content to display, and it is also common that a page may need heavy synchronous computation for initialization. The proposal allows it to contain arbitrarily complex content and arbitrarily heavy sync computation with 60FPS transition. Bytedance also showed [such a case](https://github.com/flutter/flutter/issues/110063#issuecomment-1223744653).
* **ListView scrolling**: A lot of apps have scrolling pages, and it is common to have heavy ListView children, such as a beautiful card with decorations and text. When scrolling, users want to achieve 60FPS even if those children are heavy to build/layout.
* **Locality**: @gaaclarke [said that](https://discord.com/channels/608014603317936148/608021234516754444/1022292715221831680), a few months ago [he looked at](https://discord.com/channels/608014603317936148/608021234516754444/1022292715221831680) the build/layout performance, and the thing that might be holding back layout / build is locality which will be hard to fix, with more guesses [here](https://discord.com/channels/608014603317936148/608021234516754444/1022296432738320454). (The guess will be fixed by this proposal.)
* **Heavy sync computation**: A little portion of real-world users may have to do heavy sync computation inside initState within the main isolate, because the data is not transferable or too big to send to a second isolate. (This exists, but is not the main target case that the proposal is going to solve.)
* **Dynamic usage**: There are several dynamic execution engines on Flutter, reported from blogs of some companies. Theoretically, such dynamic approaches seem to be slower than the classical AOT, so they tend to have slow build/layout phase, while the other stages such as rasterization are not slowed down, making this proposal suitable for such cases. (I personally use none, so no empirical data.)
* **Implicit scenarios**: If I understand correctly, googlers (@Hixie, @dnfield, @JonahWilliams, @gaaclarke) and bytedancers (@JsouLiang, @Nayuta) have had some discussions and experiments around solving this problem, so the problem just exists. (See [here](https://github.com/flutter/flutter/issues/101227#issuecomment-1249961627) and [here](https://discord.com/channels/608014603317936148/608021234516754444/1022292715221831680) for the chat history links)
* **Non-optimal app code**: Scenarios above mainly focus on the cases when it janks even though the code is already optimal. On the other hand, in the real world, many apps have non-optimal code in terms of performance. They could spend time digging and optimizing the app (and Flutter provides a great doc for that), but this proposal may be able to serve as a drop-in solution, so no developer time needs to be spent on performance optimization.