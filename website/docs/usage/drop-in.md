# a. Drop-in replacement

For some common scenarios, just add six letters - the "Smooth" prefix - and that's all!

:::info package current status

* The infra part is already implemented (hard, took me a month). The drop-in part and demo, which is mainly engineering work utilizing the exposed infra API, still has many improveable things, since these are the highest-level things and I spent my time mainly on the infra part. Feel free to issue and PR!
* Need to wait for all PRs to Flutter to be merged and next Flutter release. (PR status [here](https://fzyzcjy.github.io/flutter_smooth/insight/status))

:::

## `SmoothListView` replacing `ListView`

For example, before:

```dart
ListView.builder(
  itemCount: 123,
  itemBuilder: (context, index) => MyItem(),
)
```

After:

```dart
SmoothListView.builder(
  itemCount: 123,
  itemBuilder: (context, index) => MyItem(),
)
```

Then, the ListView scrolling will be smooth, even if you have very heavy content to build and layout.

## Page transition animations

For example, use `SmoothMaterialPageRoute` to replace `MaterialPageRoute`, `SmoothPageRouteBuilder` in place of `PageRouteBuilder`, etc. Then, the enter-page animation will be smooth, no matter how heavy the new page is to build and layout.

A concrete example - before:

```dart
Navigator.push(context, MaterialPageRoute(builder: MyFancyPage()));
```

After:

```dart
Navigator.push(context, SmoothMaterialPageRoute(builder: MyFancyPage()));
```

