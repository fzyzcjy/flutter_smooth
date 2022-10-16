# a. Drop-in replacement

For some common scenarios, just add six letters - the "Smooth" prefix - and that's all!

:::info

It still contains rough edges, since these are the highest-level things and I spent my time mainly on the infra part. Feel free to improve it when you face one!

:::

## `SmoothListView` replacing `ListView`

Usage:

```dart
SmoothListView.builder(
  ...
)
```

Demo:

`packages/smooth/example/lib/example_list_view/example_list_view_page.dart`

## Page transition animations

For example, `SmoothMaterialPageRoute` replaces `MaterialPageRoute`.

TODO #125