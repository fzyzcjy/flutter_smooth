class DurationRecorder {
  final _values = <Duration>[];

  void record(Duration value) => _values.add(value);

  String describe() =>
      _values.map((e) => e.inMicroseconds / 1000).toList().toString();
}

class DurationRecorders<K> {
  final _recorders = <K, DurationRecorder>{};

  DurationRecorder get(K key) => _recorders[key] ??= DurationRecorder();

  String describe() => _recorders.entries
      .map((entry) => '${_describeKey(entry.key)}=${entry.value.describe()}')
      .join('; ');

  static String _describeKey<K>(K key) {
    if (key is Enum) return key.name;
    return key.toString();
  }
}
