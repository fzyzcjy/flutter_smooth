# Introduction

Garbage collection, or GC, can cause jank when it is executed too long and pauses the main Dart code from executing (called "STW", or stop-the-world).

For example, consider a world without flutter_smooth. If UI thread originally needs 16ms to compute one frame, and GC comes and stop-the-world for 1ms (well I see GC often longer), then there must be one jank because 16ms+1ms > 16.67ms.

Luckily, with the Preempt approach (and with some modifications to the engine), flutter_smooth is *more* robust to long GC. In other words, many janks caused by GC will no longer exist if using flutter_smooth.

In the following two sections, we will discuss two dominating scenarios: when GC should happen within a long janky frame, and when GC should be triggered between frame.