# Pointer dispatch speed-up

:::info

**Title**: Speed up pointer data packet dispatching by roughly 2x when multiple packets come

**Link**: https://github.com/flutter/engine/pull/36826

:::

## Benefits for Flutter (without considering flutter_smooth)

Multiple pointer data packets often arrive in one vsync interval. Currently, each of them requires a PostTask, C++-to-Dart-call, etc. However, when there is already one *pending* PostTask and a second data packet arrives, we can optimize it - no need to schedule a second PostTask and C++-to-Dart call, but instead utilize the pending PostTask and submit more data inside one call.

How much speed up does it give: Consider the following screenshot (It happens after a long janky frame, but serves pretty well for us to compute numbers because it contains a lot of items - the average measure error will be much smaller). As we can see,

* total wall time: ~8.2ms
* total Dart time (measured by the `_handlePointerDataPacket` time, which is the 4th purple row. I made an extra Timeline event to measure that): ~3.2ms

Therefore, if we merge multiple into one, we can get roughly 2x speed up, because it removes those idle periods between them, as well as some of the big overhead between Engine::DispatchPointerDataPacket and the real Dart code execution.

![image](https://user-images.githubusercontent.com/5236035/196432743-3e1c59b0-29d8-4139-9134-25e361785515.png)
![image](https://user-images.githubusercontent.com/5236035/196433392-c76ed644-4df1-4d5d-82ab-4eea9ed3a0ed.png)

Concrete cases when this happens:

1. When it janks, this PR helps speed up. For example, many Android devices provide two data packets per vsync interval. So suppose somehow the UI thread took 30ms to compute a frame, then this approach will merge 3-4 packet deliver into one.
2. In some devices, speedup due to this PR happens in each and every time. For example, below is a tracing on a test phone. As you can see, it delivers 4 pointer data packets per frame. Consider what will happen when UI thread needs (e.g.) 15ms to compute (unlike what is in the screenshot which is very lightweight workload indeed). Then, the first 3 out of 4 packets will be able to be merged by this PR.

![image](https://user-images.githubusercontent.com/5236035/196432383-79921b20-791e-4b51-b3a7-14e671bfea41.png)


## Benefits for flutter_smooth

The analysis is similar to above. However, since there are a lot of big janky frames in flutter_smooth, it is common to see a dozen of pointer event dispatching after that long janky frame. Therefore, this PR makes that part much much faster.