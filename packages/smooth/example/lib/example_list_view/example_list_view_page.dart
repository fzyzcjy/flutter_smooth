import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

class ExampleListViewPage extends StatefulWidget {
  final bool enableSmooth;

  const ExampleListViewPage({super.key, required this.enableSmooth});

  @override
  State<ExampleListViewPage> createState() => _ExampleListViewPageState();
}

class _ExampleListViewPageState extends State<ExampleListViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example (${widget.enableSmooth ? 'smooth' : 'plain'})'),
      ),
      body: widget.enableSmooth ? _buildSmooth() : _buildPlain(),
    );
  }

  Widget _buildPlain() {
    return ListView.builder(
      itemBuilder: _buildRow,
    );
  }

  Widget _buildSmooth() {
    // TODO
    return ListView.builder(
      itemBuilder: _buildRow,
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    return SmoothPreemptPoint(
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: SizedBox(
          width: 32,
          height: 32,
          child: CircleAvatar(
            child: Text(
              'G$index',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        title: Text(
          'Foo contact from $index-th local contact',
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Stack(
          children: [
            // simulate slow build/layout; do not paint it, since much more
            // than realistic number of text
            Opacity(
              opacity: 0,
              child: Text(
                '+91 88888 8800$index ' * 120,
                style: const TextStyle(fontSize: 3),
              ),
            ),
            Text('subtitle\n' * (3 + Random().nextInt(3))),
          ],
        ),
      ),
    );
  }
}
