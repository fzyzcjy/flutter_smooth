# Setup

In this chapter, I use the following experimental setup.

:::info

If it does not reproduce on your device, please firstly try to use the code of Flutter framework and engine *at the time* when this benchmark chapter is written. This is because I have made some further experiments and merges after this benchmark, which may break the existing code and I have not tested it (given this is not merged to Flutter yet).

:::

## Testing device

All tests are done in a TRT-AL00 Android device, with Snapdragon 435.

How slow is it? [Geekbench](https://nerdschalk.com/huawei-enjoy-7-plus-benchmarks-now-available/) says it is 642 & 2867 points (single & multi core, respectively). Another rough but intuitive viewpoint is by looking at [comments](https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onReportTimings.html) on `onReportTimings` - Flutter officially says it takes <0.1ms on iPhone6S per second, while I have measured ~20ms per second. <!-- #6127 -->

As a side remark, this device has roughly 100ms latency in touching, i.e. Android system will only dispatch a touch event ~100ms after the real touch. This is OS level and Flutter has no way to overcome it.

## Testing scenario

A very common case of jank is when scrolling a `ListView`. Therefore, in this chapter, I use the [list-view-scrolling](https://github.com/fzyzcjy/flutter_smooth/blob/master/packages/smooth/example/lib/example_list_view/example_list_view_page.dart) in the example app. (The code may be refactored later, so ping me if the link becomes invalid.)

To mimic the real scenario, when a new ListView item is created, half of them will create 80 child widgets, and each of them takes 1ms to layout. Therefore, for slow scrolling, it will mimic a very heavy content that takes 80ms to layout. For fast scrolling where multiple items are created in one frame, it can be ~160ms, ~240ms etc. (Remark: These numbers may be changed in the future, so please look at code for details.)