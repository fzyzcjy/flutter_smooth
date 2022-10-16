# Installation

Add dependencies:

```yaml
dependencies:
  smooth: path/to/packages/smooth
dev_dependencies:
  smooth_dev: path/to/packages/smooth_dev # only needed if you want to write tests in app
```

:::info

This package is not yet released to `pub.dev` because it needs a custom `flutter/flutter` and `flutter/engine` build. Will release once all PRs are merged.

:::

Initialize the binding:

```Dart
void main() {
  SmoothWidgetsFlutterBinding.ensureInitialized(); // add this line in your `main` function
  // ... your original code ...
}
```

Then done.

## Use it in tests

Similar to the case above, we need to initialize the binding, but this time the one for test:

```dart
void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
}
```

