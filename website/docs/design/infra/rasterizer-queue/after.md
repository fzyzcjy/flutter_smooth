# After

I will firstly present the modified animator logic here. In the next section ("analysis"), I will then discuss why these are necessary and what problems it solves.

The changes are marked as `// CHANGE: ...` below.

```cpp
Animator::Animator()
    : layer_tree_pipeline_(std::make_shared<LayerTreePipeline>(2)) {}

void Animator::BeginFrame() {
  if (!producer_continuation_) {
    producer_continuation_ = layer_tree_pipeline_->Produce();

    if (!producer_continuation_) {
      TRACE_EVENT0("flutter", "PipelineFull");
      // CHANGE: do not return even if pipeline full
      // RequestFrame(); return;
    }
  }
  
  // CHANGE: remove this (since we do not early return if pipeline full)
  // FML_DCHECK(producer_continuation_);

  delegate_.OnAnimatorBeginFrame();
}

void Animator::Render(std::shared_ptr<flutter::LayerTree> layer_tree) {
  // CHANGE: add these several lines (if no continuation, trigger creating one if possible)
  if (!producer_continuation_) {
    producer_continuation_ = layer_tree_pipeline_->Produce();
  }
  
  // Commit the pending continuation.
  PipelineProduceResult result = producer_continuation_.Complete(layer_tree);

  if (!result.success) {
    FML_DLOG(INFO) << "No pending continuation to commit";
    return;
  }

  ... notify rasterizer ...
}
```

To summarize, there are two changes:

1. When `Render`, originally we early-return if there is no occupied seat (the continuation). However, we now produce one. (Notice the `Produce` may fail if there is really no room in pipeline.)
2. When `BeginFrame`, originally we early-return as long as the pipeline is full at that time. However, we are more optimistic and continue computing a frame even if it is full now.