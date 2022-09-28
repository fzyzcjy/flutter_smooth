import 'package:clock/clock.dart';

/// [DateTime], but simpler in memory and thus may be faster (just a `int`)
class SimpleDateTime {
  final int microsecondsSinceEpoch;

  // SimpleDateTime.fromMicrosecondsSinceEpoch(this.microsecondsSinceEpoch);

  SimpleDateTime.now()
      : microsecondsSinceEpoch = clock.now().microsecondsSinceEpoch;

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
