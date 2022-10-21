# Before

## Code

Let us firstly review the scenario before modification. Looking at [`animator.cc`](https://github.com/flutter/engine/blob/main/shell/common/animator.cc), we see the following (simplified) code:

```cpp
Animator::Animator()
    : layer_tree_pipeline_(std::make_shared<LayerTreePipeline>(2)) {}

void Animator::BeginFrame() {
  if (!producer_continuation_) {
    // We may already have a valid pipeline continuation in case a previous
    // begin frame did not result in an Animation::Render. Simply reuse that
    // instead of asking the pipeline for a fresh continuation.
    producer_continuation_ = layer_tree_pipeline_->Produce();

    if (!producer_continuation_) {
      // If we still don't have valid continuation, the pipeline is currently
      // full because the consumer is being too slow. Try again at the next
      // frame interval.
      TRACE_EVENT0("flutter", "PipelineFull");
      RequestFrame();
      return;
    }
  }
  
  // We have acquired a valid continuation from the pipeline and are ready
  // to service potential frame.
  FML_DCHECK(producer_continuation_);

  delegate_.OnAnimatorBeginFrame();
}

void Animator::Render(std::shared_ptr<flutter::LayerTree> layer_tree) {
  // Commit the pending continuation.
  PipelineProduceResult result = producer_continuation_.Complete(layer_tree);

  if (!result.success) {
    FML_DLOG(INFO) << "No pending continuation to commit";
    return;
  }

  ... notify rasterizer ...
}
```

## Summary

Briefly recall the Flutter internal implementation:

* `Animator::BeginFrame` is called in each frame, and finally calls `OnAnimatorBeginFrame` which will really call Dart side `handleBeginFrame` and `handleDrawFrame` etc.
* `Animator::Render` is called by Dart `window.render`. It is normally called after paint/composite/etc phase, and flutter_smooth call it extra times whenever we want to submit an extra frame.
* The `layer_tree_pipeline_` is a `LayerTreePipeline` with pipeline depth `2` (seen in constructor). The `Animator` is the producer of the pipeline, and the `Rasterizer` is the consumer. 

Briefly speaking, the code about pipeline works as follows:

* During `BeginFrame`, we either reuse or create a "continuation" in pipeline (i.e. occupy a seat). If we cannot, it means pipeline is full, and we skip the current frame.
* During `Render`, we put Layer tree into the occupied seat. But if there is not any occupied seat, we indeed do nothing.

