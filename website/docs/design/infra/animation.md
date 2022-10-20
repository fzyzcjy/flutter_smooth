# Animation

What happens when we put animations, such as `AnimatedBuilder` or `CircularProgressIndicator`, into the `PreemptBuilder`'s builder argument (let's name it "smooth region")? This section will tell you. No worries - it will be quite simple :)

## Background

The animations are indeed driven by `Ticker`s under the hood. An animation may look to be driven by a `AnimationController`, but under the hood that controller utilizes ticker. Luckily, `Ticker` has a minimalist API: It triggers `onTick` callback in each and every frame (this is the story without flutter_smooth).

If we only implement the infra layer using ideas before this section, animations inside smooth region will not animate at all. This is because, even though the smooth region has build/layout/paint/etc called per 16.67ms via preempt, the `AnimationController` does not see any `onTick` and thus never change the animating value, so the output UI is unchanged, thus user faces jank even though it is literally 60FPS.

## Solution

Just make extra calls to `onTick`. More specifically, one extra onTick per extra render.

Notice that we need to provide the correct time stamp to `onTick`'s argument. For example, if the first preempt render provides 1000ms, the second preempt should provide 1016.67ms, etc. By doing so, `AnimationController` will change its animation value according to the time stamp, and we see animations on screen at full smooth.