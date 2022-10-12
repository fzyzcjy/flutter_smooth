enum SmoothFramePhase {
  /// A new frame starts, and no preemptRender happens yet
  initial,

  /// Build/Layout phase preemptRender happens
  ///
  /// This can happen zero to many times in one frame
  /// If it does not happen, this variant will not appear.
  buildOrLayoutPhasePreemptRender,

  /// The plain-old pipeline renders (i.e. about to submit window.render)
  plainOldRender,

  /// AfterDrawFrame phase preemptRender happens
  ///
  /// This can happen zero or one time in one frame.
  /// If it does not happen, this variant will not appear.
  afterDrawFramePhasePreemptRender,
}
