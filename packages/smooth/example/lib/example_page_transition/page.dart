import 'package:example/example_page_transition/sub_page.dart';
import 'package:example/utils/page_utils.dart';
import 'package:flutter/material.dart';

class ExamplePageTransitionPage extends StatelessWidget {
  const ExamplePageTransitionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example: Page transition')),
      body: Builder(
        builder: (context) => ListView(
          children: [
            PageUtils.buildRow(
                const ExamplePageTransitionSubPage(enableSmooth: false),
                'Example: Plain'),
            PageUtils.buildRow(
                const ExamplePageTransitionSubPage(enableSmooth: true),
                'Example: Smooth'),
          ],
        ),
      ),
    );
  }
}
