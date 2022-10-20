# Report timing slowness

:::info

**Title**: Allow disable report timing in profile build since it takes not-negligible amount of time

**Link**: https://github.com/flutter/flutter/pull/113526

:::

Flutter [does say](https://api.flutter.dev/flutter/dart-ui/PlatformDispatcher/onReportTimings.html) the time cost is "less than 0.1ms every 1 second to report the timings measured on iPhone6S". However, not every mobile phone is as high-end as iPhone6S. For example, on my testing device (TRT-AL00, indeed not the lowest-end device!), I measured that it takes about 20-30ms per second. Then we have a problem. When having https://github.com/fzyzcjy/flutter_smooth, we know a big janky frame (say, takes 200ms) will never let user really feel janky, but instead user will see the app being 60FPS smooth. However, this is based on the assumption that misc work such as report timings should not block the UI thread for a continuous period of time - which is not true if report timings happens. After the 200ms janky frame, we see about 6ms of report timing. Among with other things such as dispatch touch events, they easily take up more than ~16ms and we get one jank. Then flutter_smooth is no longer smooth due to the jank.

Except for the case of flutter_smooth, IMHO this PR is also useful for normal Flutter users. It takes 2-3% of CPU time, which is not negligible and may be measured. In addition, this is not a critical feature. Surely, when this is disabled, the DevTool will not show the frame ui/rasterizer time at all. However, not everyone needs to read that timing data, since they may either do not open DevTool, or use the tracing timeline instead (which contains more than enough information to know the frame timing data). Therefore, it looks reasonable to at least give users a *chance* (i.e. a flag) to disable it.

The code is deliberately written by reading a const bool environment variable. Therefore, it has completely zero overhead. I have confirmed that by using compiler explorer before - https://discordapp.com/channels/608014603317936148/608021234516754444/1024141682377236500.