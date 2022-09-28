import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';

/// [DateTime], but simpler in memory and thus may be faster (just a `int`)
@immutable
class SimpleDateTime {
  final int microsecondsSinceEpoch;

  const SimpleDateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch);

  SimpleDateTime.now()
      : microsecondsSinceEpoch = clock.now().microsecondsSinceEpoch;

  static const zero = SimpleDateTime.fromMicrosecondsSinceEpoch(0);

  SimpleDateTime add(Duration d) => SimpleDateTime.fromMicrosecondsSinceEpoch(
      microsecondsSinceEpoch + d.inMicroseconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleDateTime &&
          runtimeType == other.runtimeType &&
          microsecondsSinceEpoch == other.microsecondsSinceEpoch;

  @override
  int get hashCode => microsecondsSinceEpoch.hashCode;

  @override
  String toString() => 'SimpleDateTime($microsecondsSinceEpoch)';
}

SimpleDateTime maxSimpleDateTime(SimpleDateTime a, SimpleDateTime b) =>
    a.microsecondsSinceEpoch > b.microsecondsSinceEpoch ? a : b;
