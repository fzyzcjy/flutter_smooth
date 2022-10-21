# Before

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

  delegate_.OnAnimatorBeginFrame();
}

void Animator::Render() {
  // Commit the pending continuation.
  PipelineProduceResult result = producer_continuation_.Complete();

  if (!result.success) {
    FML_DLOG(INFO) << "No pending continuation to commit";
    return;
  }

  if (!result.is_first_item) {
    // It has been successfully pushed to the pipeline but not as the first
    // item. Eventually the 'Rasterizer' will consume it, so we don't need to
    // notify the delegate.
    return;
  }

  delegate_.OnAnimatorDraw(layer_tree_pipeline_);
}
```

