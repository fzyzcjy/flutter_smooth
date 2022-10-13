import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';

class TimeInfo {
  final testBeginTime = clock.now();

  Duration calcPumpDurationAuto() {
    final now = clock.now();
    final smoothFrameIndex =
        ((now.difference(testBeginTime).inMicroseconds + 1) /
                kOneFrame.inMicroseconds)
            .ceil();
    return calcPumpDuration(smoothFrameIndex: smoothFrameIndex);
  }

  Duration calcPumpDuration({required int smoothFrameIndex}) {
    final targetTime = testBeginTime.add(kOneFrame * smoothFrameIndex);
    final now = clock.now();
    final pumpDuration = targetTime.difference(now);

    expect(pumpDuration, greaterThan(Duration.zero),
        reason: 'cannot pump into the past');
    expect(pumpDuration, lessThanOrEqualTo(kOneFrame),
        reason: 'looks like you are pumping to far future');

    return pumpDuration;
  }
 
  DateTime fromBegin(Duration delta) => testBeginTime.add(delta);
}
