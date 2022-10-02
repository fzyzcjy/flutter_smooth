import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

class ExampleListViewPage extends StatefulWidget {
  const ExampleListViewPage({super.key});

  @override
  State<ExampleListViewPage> createState() => _ExampleListViewPageState();
}

class _ExampleListViewPageState extends State<ExampleListViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: ListView.builder(
        itemBuilder: (_, index) => SmoothPreemptPoint(
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
        ),
      ),
    );
  }
}
