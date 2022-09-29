// TODO make FPS non-const (i.e. changeable according to different devices)
const kFps = 60;
const kOneFrameUs = 1000000 ~/ kFps;
const kOneFrame = Duration(microseconds: kOneFrameUs);
