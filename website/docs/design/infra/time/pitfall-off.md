# Pitfall: Off-by-1-frame

:::caution

This is critical to understand most time-related code in the package. For example, I may write down something equivalent to "if `now() + 2ms > SchedulerBinding.currentSystemFrameTimeStamp` then preempt", and it is nonsense if you misunderstand this pitfall.

:::

Suppose it is 8 o'clock and we receive a `handleBeginFrame(Duration? timeStamp)`. Then, what time stamp do you think we will get? The time stamp corresponding to 8 o'clock?

No! Indeed it is a time stamp representing "8 o'clock + 16.67ms". This is the 1-frame shift pitfall in the title.

Why? Digging into the source code (as discussed below), we see the values is gotten via `frame_timings_recorder_->GetVsyncTargetTime()`. In addition, "vsync *target* time" means the "8 o'clock + 16.67ms" instead of "8 o'clock". You can confirm this by using timeline tracing or logging.

By the way, as discussed below, that `timeStamp` has time base as `SystemFrameTimeStamp`, not `DateTime`.