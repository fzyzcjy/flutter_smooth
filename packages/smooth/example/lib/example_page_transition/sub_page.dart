import 'package:example/utils/complex_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ExamplePageTransitionSubPage extends StatefulWidget {
  final bool enableSmooth;
  final int listTileCount;
  final WidgetWrapper? wrapListTile;

  const ExamplePageTransitionSubPage({
    super.key,
    required this.enableSmooth,
    this.listTileCount = 150,
    this.wrapListTile,
  });

  @override
  State<ExamplePageTransitionSubPage> createState() =>
      _ExamplePageTransitionSubPageState();
}

class _ExamplePageTransitionSubPageState
    extends State<ExamplePageTransitionSubPage> {
  var tapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Page')),
      body: Builder(
        builder: (context) => Center(
          child: GestureDetector(
            onTap: () => _handleTap(context),
            child: Text(
              tapped ? 'Tapped, page is loading' : 'Tap me',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    setState(() {
      tapped = true;
    });

    // wait a frame, such that we can tell reader it is tapped
    // even for the janky non-smooth case
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // TODO use our page route
      Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (_) => _SecondPage(
            listTileCount: widget.listTileCount,
            wrapListTile: widget.wrapListTile,
          ),
        ),
      );
    });
  }
}

class _SecondPage extends StatefulWidget {
  final int listTileCount;
  final WidgetWrapper? wrapListTile;

  const _SecondPage({
    required this.listTileCount,
    required this.wrapListTile,
  });

  @override
  State<_SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<_SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: ComplexWidget(
        listTileCount: widget.listTileCount,
        wrapListTile: widget.wrapListTile,
      ),
    );
  }
}
