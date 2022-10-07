// TODO may not exist after prorotyping
class SimpleLog {
  static final instance = SimpleLog._();

  SimpleLog._();

  final _messages = <String>[];

  void log(String value) => _messages.add(value);

  void dumpAndReset() {
    for (final log in _messages) {
      print(log);
    }
  }
}
