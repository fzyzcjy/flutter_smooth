import 'package:clock/clock.dart';

/// [DateTime], but simpler in memory and thus may be faster (just a `int`)
class SimpleDateTime {
  final int microsecondsSinceEpoch;

  SimpleDateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch);

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

extension ExtClock on Clock {
  SimpleDateTime nowSimple() => clock.now().toSimple();
}

extension ExtDateTime on DateTime {
  SimpleDateTime toSimple() =>
      SimpleDateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
}
