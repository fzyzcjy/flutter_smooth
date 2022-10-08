import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/messages_wrapped.dart';
import 'package:smooth/src/service_locator.dart';

class ExtraEventDispatcher {
  final _pendingEventManager = _PendingPointerEventManager();

  // TODO just prototype, not final code
  // #5867
  void dispatch({required Duration smoothFrameTimeStamp}) {
    final gestureBinding = GestureBinding.instance;

    final pointerEventDateTimeDiffTimeStamp =
        SmoothHostApiWrapped.instance.pointerEventDateTimeDiffTimeStamp;
    if (pointerEventDateTimeDiffTimeStamp == null) {
      // not finish initialization
      return;
    }

    final now = clock.now();
    final nowTimeStampInPointerEventClock = Duration(
        microseconds:
            now.microsecondsSinceEpoch - pointerEventDateTimeDiffTimeStamp);

    print(
        'pointerEventDateTimeDiffTimeStamp=$pointerEventDateTimeDiffTimeStamp');

    // print('hackDispatchExtraPointerEvents '
    //     'pointer=$pointer '
    //     'hitTest=${gestureBinding.hitTests[pointer]!}');

    // final pendingEvents = gestureBinding.readEnginePendingEventsAndClear();

    // in order to mimic classical case
    // details see #6066
    final pendingEventMaxTimeStamp = smoothFrameTimeStamp - kOneFrame;
    final pendingEvents = _pendingEventManager.read(
        maxTimeStampClockScheduler: pendingEventMaxTimeStamp);

    // print(
    //     'pendingPacket.len=${pendingPacket.data.length} pendingPacket.data=${pendingPacket.data}');

    // // WARN: this fake event is VERY dummy! many fields are not filled in
    // // so a real consumer of pointer event may get VERY confused!
    // final event = PointerMoveEvent(
    //   pointer: pointer,
    //   position: Offset(_nextDummyPosition, _nextDummyPosition),
    // );
    // _nextDummyPosition = (_nextDummyPosition + 10) % 300;

    final interestPipelineOwners = ServiceLocator
        .instance.auxiliaryTreeRegistry.trees
        .map((tree) => tree.pipelineOwner)
        .toList();

    // NOTE only deal with those events that does *not* require a [hitTest]
    //      pointer *move* events are such kind.
    final interestEvents = pendingEvents.whereType<PointerMoveEvent>().toList();

    // https://github.com/fzyzcjy/yplusplus/issues/5867#issuecomment-1263053441
    for (final event in interestEvents) {
      // TODO this is WRONG, will cause duplicate event sending! #5875
      gestureBinding.handlePointerEvent(
        event,
        filter: (entry) {
          final target = entry.target;
          return target is RenderObject &&
              interestPipelineOwners.contains(target.owner);
        },
      );
    }
  }
}

class _PendingPointerEventManager {
  final _pendingEvents = Queue<PointerEvent>();

  /// [maxTimeStampClockScheduler] has the same clock as [SchedulerBinding.currentFrameTimeStamp]
  List<PointerEvent> read({required Duration maxTimeStampClockScheduler}) {
    final maxTimeStampClockPointerEvent =
        timeStampClockSchedulerToClockPointerEvent(maxTimeStampClockScheduler);
    if (maxTimeStampClockPointerEvent == null) {
      // not initialized
      return const [];
    }

    _fetchFromEngine(
        sanityCheckLastEventTimeStamp: maxTimeStampClockPointerEvent);

    final ans = <PointerEvent>[];
    while (_pendingEvents.isNotEmpty &&
        _pendingEvents.first.timeStamp < maxTimeStampClockPointerEvent) {
      ans.add(_pendingEvents.removeFirst());
    }
    return ans;
  }

  void _fetchFromEngine({required Duration sanityCheckLastEventTimeStamp}) {
    final gestureBinding = GestureBinding.instance;

    final enginePendingEvents =
        gestureBinding.readEnginePendingEventsAndClear();

    assert(() {
      // be very loose
      const kThreshold = Duration(milliseconds: 20);

      final eventTimeStamp = enginePendingEvents.lastOrNull?.timeStamp;
      if (eventTimeStamp != null &&
          (eventTimeStamp - sanityCheckLastEventTimeStamp).abs() > kThreshold) {
        throw AssertionError(
            'sanityCheckPointerEventTime failed: eventTimeStamp=$eventTimeStamp sanityCheckLastEventTimeStamp=$sanityCheckLastEventTimeStamp');
      }
      return true;
    }());

    _pendingEvents.addAll(enginePendingEvents);

    assert(_isNonDecreasing(
        _pendingEvents.map((e) => e.timeStamp.inMicroseconds).toList()));
  }

  static Duration? timeStampClockSchedulerToClockPointerEvent(
      Duration timeClockScheduler) {
    final pointerEventDateTimeDiffTimeStamp =
        SmoothHostApiWrapped.instance.pointerEventDateTimeDiffTimeStamp;
    if (pointerEventDateTimeDiffTimeStamp == null) return null;

    final dateTime = ServiceLocator.instance.preemptStrategy
        .timeStampToDateTime(timeClockScheduler);

    return Duration(
        microseconds: dateTime.microsecondsSinceEpoch -
            pointerEventDateTimeDiffTimeStamp);
  }
}

bool _isNonDecreasing(List<int> values) {
  for (var i = 0; i < values.length - 1; ++i) {
    if (values[i] > values[i + 1]) return false;
  }
  return true;
}
