# Installation

## 1. Add dependencies

```yaml
dependencies:
  smooth: path/to/packages/smooth
dev_dependencies:
  smooth_dev: path/to/packages/smooth_dev # only needed if you want to write tests in app
```

:::info

This package is not yet released to `pub.dev` because it needs a custom `flutter/flutter` and `flutter/engine` build. Will release once all PRs are merged.

:::

## 2. Initialization

```Dart
void main() {
  SmoothWidgetsFlutterBinding.ensureInitialized(); // add this line
  // ... your original code ...
}
```

## 3. Add parent

Wrap your tree with `SmoothParent`:

```dart
SmoothParent(
  child: /*... your original child such as MaterialApp ...*/
)
```

## 4. Add point

:::info

This will *no longer* be needed, if the PR to enhance performLayout to Flutter is merged.

:::

Put `SmoothPoint` in many places your widget tree, roughly making each child subtree less than 1ms to build or layout. No need to be accurate about the 1ms - just ensure putting enough of it and it is done.

(WIP) If you put too coarse `SmoothPoint`s, the system will warn you.

## Use it in tests

Similar to the case above, we need to initialize the binding, but this time the one for test:

```dart
void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
}
```

