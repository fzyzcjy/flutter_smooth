/// Typed duration. Just like [DurationT<Coord>], but with marker [Coord] to denote what
/// coordinate system it is in
// source code ref [Duration]
class DurationT<Coord> implements Comparable<DurationT<Coord>> {
  final int _duration;

  /// "unchecked" because we cannot verify the [microseconds] is in [Coord] space
  const DurationT.unchecked({required int microseconds})
      : this._microseconds(microseconds);

  DurationT.uncheckedFrom(Duration d) : this._microseconds(d.inMicroseconds);

  const DurationT._microseconds(this._duration);

  DurationT<Coord> operator +(DurationT<Coord> other) =>
      DurationT._microseconds(_duration + other._duration);

  DurationT<Coord> operator -(DurationT<Coord> other) =>
      DurationT._microseconds(_duration - other._duration);

  DurationT<Coord> operator *(num factor) =>
      DurationT._microseconds((_duration * factor).round());

  DurationT<Coord> operator ~/(int quotient) =>
      DurationT._microseconds(_duration ~/ quotient);

  bool operator <(DurationT<Coord> other) => this._duration < other._duration;

  bool operator >(DurationT<Coord> other) => this._duration > other._duration;

  bool operator <=(DurationT<Coord> other) => this._duration <= other._duration;

  bool operator >=(DurationT<Coord> other) => this._duration >= other._duration;

  int get inMicroseconds => _duration;

  @override
  bool operator ==(Object other) =>
      other is DurationT<Coord> && _duration == other._duration;

  @override
  int get hashCode => _duration.hashCode;

  @override
  int compareTo(DurationT<Coord> other) => _duration.compareTo(other._duration);

  @override
  String toString() => Duration(microseconds: _duration).toString();

  DurationT<Coord> abs() => DurationT._microseconds(_duration.abs());

  DurationT<Coord> operator -() => DurationT._microseconds(0 - _duration);
}
