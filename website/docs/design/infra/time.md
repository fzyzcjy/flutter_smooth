# All about time

It may look surprising I have a section discussing time, but there are some pitfalls here indeed.

## Pitfall: The 1-frame shift

TODO

## Several time bases

They can be converted back and forth via `TimeConverter` class.

### `DateTime.now()`, `SimpleDateTime.now()`

The one everyone is familiar with.

The `SimpleDateTime` has same semantics as `DateTime` but probably more lightweight.

### `SystemFrameTimeStamp`, `fml::TimePoint`

Who uses it

* `SchedulerBinding.currentSystemFrameTimeStamp`
* The "rawTimeStamp" argument in `handleBeginFrame(Duration? rawTimeStamp)`
* The `fml::TimePoint` use extensively in the C++ engine.

Notice the engine wants to accept `fml::TimePoint` most of the time. Therefore, for example, when we want to submit a vsync target time to engine, we should (usually) convert it to `fml::TimePoint`.

By the way, the dig if you are interested:

<details>

```c++
// animator.cc
  const fml::TimePoint frame_target_time =
      frame_timings_recorder_->GetVsyncTargetTime();
  delegate_.OnAnimatorBeginFrame(frame_target_time, frame_number);

// ... which finally calls platfrom_configuration.cc
void PlatformConfiguration::BeginFrame(fml::TimePoint frameTime,
                                       uint64_t frame_number) {
  tonic::CheckAndHandleError(
      tonic::DartInvoke(begin_frame_.Get(), {
                                                Dart_NewInteger(microseconds),
                                                Dart_NewInteger(frame_number),
                                            }));
}
```

</details>

### `AdjustedFrameTimeStamp`, `Ticker`

Who uses it

* `SchedulerBinding.currentFrameTimeStamp`
* The time stamp passed from `Ticker`'s onTick callback

As can be seen in `SchedulerBinding` source code, this one is effectively converted from `SchedulerBinding.currentSystemFrameTimeStamp`  by `_adjustForEpoch` method.

### `PointerEventTimeStamp`, `PointerEvent.timeStamp`

Who uses it:

* `PointerEvent.timeStamp`

Digging into code, we see it comes from a time stamp provided together with pointer events from the Android and iOS operating system.

The dig if you are interested:

<details>

#### Android

```c++
static void DispatchPointerDataPacket(JNIEnv* env,
                                      jobject jcaller,
                                      jlong shell_holder,
                                      jobject buffer,
                                      jint position) {
  uint8_t* data = static_cast<uint8_t*>(env->GetDirectBufferAddress(buffer));
  auto packet = std::make_unique<flutter::PointerDataPacket>(data, position);
  ANDROID_SHELL_HOLDER->GetPlatformView()->DispatchPointerDataPacket(
      std::move(packet));
}

...

      // Start of methods from FlutterView
      {
          .name = "nativeDispatchPointerDataPacket",
          .signature = "(JLjava/nio/ByteBuffer;I)V",
          .fnPtr = reinterpret_cast<void*>(&DispatchPointerDataPacket),
      },
```

FlutterJNI.java

```java
  // ------ Start Touch Interaction Support ---
  /** Sends a packet of pointer data to Flutter's engine. */
  @UiThread
  public void dispatchPointerDataPacket(@NonNull ByteBuffer buffer, int position) {
    ensureRunningOnMainThread();
    ensureAttachedToNative();
    nativeDispatchPointerDataPacket(nativeShellHolderId, buffer, position);
  }
```

AndroidTouchProcessor.java

```java
  public boolean onTouchEvent(@NonNull MotionEvent event, @NonNull Matrix transformMatrix) {
    addPointerForIndex;
    renderer.dispatchPointerDataPacket(packet, packet.position());

  private void addPointerForIndex(MotionEvent event
    long timeStamp = event.getEventTime() * 1000; // Convert from milliseconds to microseconds.
```

https://developer.android.com/reference/android/view/MotionEvent#getEventTime()

> Retrieve the time this event occurred, in the [SystemClock.uptimeMillis()](https://developer.android.com/reference/android/os/SystemClock#uptimeMillis()) time base.

Thus it is `SystemClock.uptimeMillis`.

#### iOS

FlutterEngine.mm

```objc
- (void)dispatchPointerDataPacket:(std::unique_ptr<flutter::PointerDataPacket>)packet {
  if (!self.platformView) {
    return;
  }
  self.platformView->DispatchPointerDataPacket(std::move(packet));
}
```

Then

```objc
// Dispatches the UITouches to the engine. Usually, the type of change of the touch is determined
// from the UITouch's phase. However, FlutterAppDelegate fakes touches to ensure that touch events
// in the status bar area are available to framework code. The change type (optional) of the faked
// touch is specified in the second argument.
- (void)dispatchTouches:(NSSet*)touches
    pointerDataChangeOverride:(flutter::PointerData::Change*)overridden_change
                        event:(UIEvent*)event {
  [_engine.get() dispatchPointerDataPacket:std::move(packet)];
```

About timestamp generation:

```objc
- (void)dispatchTouches:(NSSet*)touches
    pointer_data.time_stamp = touch.timestamp * kMicrosecondsPerSecond;

- (flutter::PointerData)generatePointerDataForFake {
  // `UITouch.timestamp` is defined as seconds since system startup. Synthesized events can get this
  // time with `NSProcessInfo.systemUptime`. See
  // https://developer.apple.com/documentation/uikit/uitouch/1618144-timestamp?language=objc
  pointer_data.time_stamp = [[NSProcessInfo processInfo] systemUptime] * kMicrosecondsPerSecond;
```

Thus, it is`UITouch.timestamp`, indeed also system uptime.

https://developer.apple.com/documentation/uikit/uitouch/1618144-timestamp?language=objc

> The value of this property is the time, in seconds since system startup, that the touch originated or was last changed. 
> For a definition of the time since system startup, see the description of the [systemUptime](https://developer.apple.com/documentation/foundation/nsprocessinfo/1414553-systemuptime?language=objc) method of the [NSProcessInfo](https://developer.apple.com/documentation/foundation/nsprocessinfo?language=objc) class.

</details>

