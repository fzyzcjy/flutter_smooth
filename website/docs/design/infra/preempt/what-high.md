# PreemptBuilder

If this package stops at the API above, nobody will use it - you will have to write a ton of code to modify the `Layer` tree by yourself. The goal in this part is to create a developer-friendly API, indeed the `PreemptBuilder`. Recall the definition of `PreemptBuilder(builder: ..., child: ...)` - put the things that you want to be smooth inside the builder, and we are done. How is that implemented?

The core idea is to use an auxiliary tree in addition to the main tree. In other words, we create a separate `BuildOwner`, `PipelineOwner`, root widget, etc. Then, we are free to call its `buildScope`, `flushLayout`, `flushPaint`, etc, at *any time* at any frequency we like. Its input is a widget tree (indeed `PreemptBuilder.builder` output), and its output is a `Layer` tree (indeed to be inserted to the main tree).

Then, we need to graft the auxiliary-tree’s layer tree and the main-tree’s layer tree. Shortly speaking, we do so in `paint` function by `context.addLayer` and so on. Details can be found in the code.

So, the modified pseudo-code looks like:

```dart
void preemptRender() {
  auxiliaryTree.buildScope(), flushLayout(), flushPaint(); // affect layer subtree of auxiliary tree, thus also the main tree
  window.render(buildScene(flutterMainLayerTree));
}
```

