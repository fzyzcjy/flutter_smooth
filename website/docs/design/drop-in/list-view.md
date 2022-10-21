# SmoothListView

:::info

To use the package, there is no need to understand this section since it is implementation details. This section is for those who are interested in knowing what happens under the hood.

:::

The core code is simple:

```dart
return SmoothBuilder(
  builder: (context, child) => SmoothShift(...),
  child: ListView(...),
);
```

When the user is dragging `ListView`, the `_SmoothShiftSourcePointerEvent` will listen to those `PointerMoveEvent` (via a normal `Listener` widget), and provide proper shifting.

When the user has released the finger, i.e. `ListView` is now ballistic shifting by inertia, the `_SmoothShiftSourceBallistic` comes and provide proper shifting during preempt rendering.

When the user is releasing his finger (`PointerUpEvent`), we can implement is just like the two cases above. However, to illustrate the ability of the "Brake" mechanism, I trigger a brake when this happens.
