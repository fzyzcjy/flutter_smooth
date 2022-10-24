# SmoothMaterialPageRoute

:::info

To use the package, there is no need to understand this section since it is implementation details. This section is for those who are interested in knowing what happens under the hood.

:::

## Core

Let's start from the simple, by building a page transition animation without worrying how to adapt to the existing `PageRoute` system.

That is pretty simple:

```dart
return SmoothBuilder(
  builder: (context, child) => SmoothPageTransition(child: child),
  child: MySecondPage(),
);
```

The `SmoothPageTransition` can be implemented as something like the following. (To demonstrate the idea more clearly, the code deliberately lacks things like creating a Tween, disposing controller, starting a controller, widget fields, etc)

```dart
class SmoothPageTransition extends StatefulWidget {...}
class _SmoothPageTransitionState extends State<SmoothPageTransition> with SingleTickerProviderStateMixin {
  final controller = AnimationController(vsync: this);
  Widget build(BuildContext context) => SlideTransition(
    position: controller.value,
    child: widget.child,
  );
}
```

## Adapt to `PageRoute`

Now comes the problem: We cannot directly use the `Animation`s exposed from `PageRoute.buildTransitions`, because the `Ticker`s driving those animations never fire at extra preempt rendering.

Looking at the source code (`SmoothPageRouteMixin`), I did a small trick: I create a class, `DualProxyAnimationController`, which behaves like an `AnimationController`, but secretly passes all write operations to another secondary AnimationController. Then, for that secondary controller, I let the extra onTick be fired when extra preempt rendering. Then we are done.
