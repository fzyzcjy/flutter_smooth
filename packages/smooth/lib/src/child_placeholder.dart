import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:smooth/src/adapter_in_auxiliary_tree.dart';
import 'package:smooth/src/auxiliary_tree_pack.dart';

class SmoothChildPlaceholderRegistry {
  late final slots = UnmodifiableListView(_slots);
  final _slots = <Object>{};

  void _register(Object slot) {
    assert(!_slots.contains(slot));
    _slots.add(slot);
  }

  void _unregister(Object slot) {
    assert(_slots.contains(slot));
    _slots.remove(slot);
  }
}

class SmoothChildPlaceholderRegistryProvider extends InheritedWidget {
  final SmoothChildPlaceholderRegistry registry;

  const SmoothChildPlaceholderRegistryProvider({
    super.key,
    required this.registry,
    required super.child,
  });

  static SmoothChildPlaceholderRegistryProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<
          SmoothChildPlaceholderRegistryProvider>()!;

  @override
  bool updateShouldNotify(SmoothChildPlaceholderRegistryProvider old) =>
      old.registry != registry;
}

class SmoothChildPlaceholder extends StatelessWidget {
  final Object slot;

  const SmoothChildPlaceholder({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    return _SmoothChildPlaceholderInner(
      registry: SmoothChildPlaceholderRegistryProvider.of(context).registry,
      slot: slot,
    );
  }
}

class _SmoothChildPlaceholderInner extends StatefulWidget {
  final SmoothChildPlaceholderRegistry registry;
  final Object slot;

  const _SmoothChildPlaceholderInner(
      {required this.registry, required this.slot});

  @override
  State<_SmoothChildPlaceholderInner> createState() =>
      _SmoothChildPlaceholderInnerState();
}

class _SmoothChildPlaceholderInnerState
    extends State<_SmoothChildPlaceholderInner> {
  @override
  void initState() {
    super.initState();
    widget.registry._register(widget.slot);
  }

  @override
  void didUpdateWidget(covariant _SmoothChildPlaceholderInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slot != widget.slot ||
        oldWidget.registry != widget.registry) {
      oldWidget.registry._unregister(oldWidget.slot);
      widget.registry._register(widget.slot);
    }
  }

  @override
  void dispose() {
    widget.registry._unregister(widget.slot);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // hack, since AdapterInAuxiliaryTreeWidget not deal with offset yet
    return RepaintBoundary(
      child: AdapterInAuxiliaryTreeWidget(
        slot: widget.slot,
        pack: AuxiliaryTreePackProvider.of(context).pack,
      ),
    );
  }
}
