# What to do

Abstractly speaking, we should produce a new UI when doing a preempt. For example, when showing enter-page animation, the new UI will be a screen shifting pixel by pixel as time goes by.

More concretely, what is the new UI? This needs some background of Flutter internal implementation. The UI that the ui thread submits to rasterizer thread is indeed a `Scene` object, and it is submitted to rasterizer via `window.render`.

## How to create `Scene`

So how can we create the latest UI inside the preempt render? Let's firstly discuss the lowest-level approach, and below we will provide a wrapper so users can create widgets easily.

Recall how Flutter is implemented. During a normal frame pipeline, the build and layout phase modifies `RenderObject` (and other things), while the `Layer` tree is untouched and is still old (i.e. has content from last frame). During the paint phase, `RenderObject` will modify the `Layer` tree by utilizing its new data. Finally, the `Scene` is built from the `Layer` tree, and submitted to rasterizer via `window.render`.

Recall the preempt render is called *inside* the build or layout phase. Therefore, during a preempt render, we have dirty `RenderObject` tree and should not utilize it. However, the `Layer` tree is, foruntately, non-dirty and ready to be used, with content generated from the plain-old rendering in the *last* frame.

Now consider what happens during a preempt render. For simplicity, suppose we are doing a page-enter animation, and the widget handling page shifting is bound to a specific `OffsetLayer`. Then, inside preempt render, we simply do something like `thatOffsetLayer.offset += 10px`. By doing so, the UI will have the new page shifted a bit, i.e. the animation progresses a bit. After that, we can submit the whole layer tree object to rasterizer (indeed convert to `Scene` and call `window.render`).

Thus, we now have a mechanism for 60FPS smooth animation, no matter how heavy the tree is to build/layout.

Pseudo-code is like this:

```dart
void preemptRender() {
  flutterMainLayerTree.thatOffsetLayer.offset += 10px;
  window.render(buildScene(flutterMainLayerTree));
}
```

No worries, this is not the end - see next section for how we make it developer friendly.
