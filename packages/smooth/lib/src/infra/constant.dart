import 'package:smooth/src/infra/time/typed_time.dart';

// TODO make FPS non-const (i.e. changeable according to different devices)

const kFps = 60;
const kOneFrameUs = 1000000 ~/ kFps;
const kOneFrame = Duration(microseconds: kOneFrameUs);

// AFTS: AdjustedFrameTimeStamp
const kOneFrameAFTS =
    AdjustedFrameTimeStamp.unchecked(microseconds: kOneFrameUs);
