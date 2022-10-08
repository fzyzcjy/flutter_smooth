import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
    final pendingEvents =
        _pendingEventManager.read(maxTimeStamp: pendingEventMaxTimeStamp);

    // print(
    //     'pendingPacket.len=${pendingPacket.data.length} pendingPacket.data=${pendingPacket.data}');

    _sanityCheckPointerEventTime(
      eventTimeStamp: pendingEvents.lastOrNull?.timeStamp,
      nowTimeStamp: nowTimeStampInPointerEventClock,
    );

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

  static void _sanityCheckPointerEventTime({
    required Duration? eventTimeStamp,
    required Duration nowTimeStamp,
  }) {
    // be very loose
    const kThreshold = Duration(milliseconds: 20);
    if (eventTimeStamp != null &&
        (eventTimeStamp - nowTimeStamp).abs() > kThreshold) {
      throw AssertionError(
          'sanityCheckPointerEventTime failed: eventTimeStamp=$eventTimeStamp nowTimeStamp=$nowTimeStamp');
    }
  }
}

class _PendingPointerEventManager {
  final _pendingEvents = Queue<PointerEvent>();

  List<PointerEvent> read({required Duration maxTimeStamp}) {
    final gestureBinding = GestureBinding.instance;
    _pendingEvents.addAll(gestureBinding.readEnginePendingEventsAndClear());

    assert(_isNonDecreasing(
        _pendingEvents.map((e) => e.timeStamp.inMicroseconds).toList()));

    final ans = <PointerEvent>[];
    while (_pendingEvents.isNotEmpty &&
        _pendingEvents.first.timeStamp < maxTimeStamp) {
      ans.add(_pendingEvents.removeFirst());
    }
    return ans;
  }
}

bool _isNonDecreasing(List<int> values) {
  for (var i = 0; i < values.length - 1; ++i) {
    if (values[i] > values[i + 1]) return false;
  }
  return true;
}
