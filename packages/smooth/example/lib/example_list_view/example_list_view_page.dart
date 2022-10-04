import 'dart:math';

import 'package:example/utils/debug_plain_animation.dart';
import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

class ExampleListViewPage extends StatefulWidget {
  final bool enableSmooth;

  const ExampleListViewPage({super.key, required this.enableSmooth});

  @override
  State<ExampleListViewPage> createState() => _ExampleListViewPageState();
}

class _ExampleListViewPageState extends State<ExampleListViewPage> {
  var workload = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example (${widget.enableSmooth ? 'smooth' : 'plain'})'),
      ),
      body: Column(
        children: [
          const CounterWidget(prefix: 'Plain: '),
          SizedBox(
            height: 36,
            child: SmoothBuilder(
              builder: (_, __) => const Directionality(
                textDirection: TextDirection.ltr,
                child: CounterWidget(prefix: 'Smooth: '),
              ),
              child: Container(),
            ),
          ),
          Expanded(child: widget.enableSmooth ? _buildSmooth() : _buildPlain()),
          Row(
            children: [
              for (final value in [1, 10, 20, 50, 100, 200])
                SizedBox(
                  width: 48,
                  child: TextButton(
                    onPressed: () => setState(() => workload = value),
                    child: Text('$value'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlain() {
    return ListView.builder(
      itemCount: 1000,
      itemBuilder: _buildRow,
    );
  }

  Widget _buildSmooth() {
    return SmoothListView.builder(
      itemCount: 1000,
      itemBuilder: _buildRow,
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: SizedBox(
        width: 32,
        height: 32,
        child: CircleAvatar(
          backgroundColor: Colors.primaries[index % Colors.primaries.length],
          child: Text(
            'G$index',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      title: Text(
        'Item $index',
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Stack(
        children: [
          for (var i = 0; i < workload; ++i)
            SmoothPreemptPoint(
              child: SizedBox(
                height: 36,
                child: OverflowBox(
                  // simulate slow build/layout; do not paint it, since much more
                  // than realistic number of text
                  child: Opacity(
                    opacity: 0,
                    child: Text(
                      '+91 88888 8800$index ' * 100,
                      style: const TextStyle(fontSize: 3),
                    ),
                  ),
                ),
              ),
            ),
          Text('a\n' * (3 + Random().nextInt(3))),
        ],
      ),
    );
  }
}
