# b. SmoothBuilder

When you need arbitrary content to be smooth, here it goes:

```dart
SmoothBuilder(
  builder: (context, child) => ...,
  child: ...,
);
```

Indeed, it has almost identical signature as classical Flutter widgets such as `AnimatedBuilder`.

Shortly speaking, the whole app runs at normal FPS, while the thing *inside* the `builder` callback will be 60FPS smooth. Therefore, for example, put animations there.
