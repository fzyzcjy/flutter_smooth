import 'dart:ui';

class OnceCallable {
  VoidCallback? _callable;

  set once(VoidCallback value) {
    assert(_callable == null);
    _callable = value;
  }

  void call() {
    _callable?.call();
    _callable = null;
  }

  bool get hasPending => _callable != null;
}
