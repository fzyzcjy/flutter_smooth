import 'package:example/example_page_transition/sub_page.dart';
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
            _buildItem(const ExamplePageTransitionSubPage(enableSmooth: false),
                'Example: Plain'),
            _buildItem(const ExamplePageTransitionSubPage(enableSmooth: true),
                'Example: Smooth'),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Widget page, String title) {
    return Builder(
      builder: (context) => ListTile(
        title: Text(title),
        onTap: () => Navigator.push<dynamic>(
            context, MaterialPageRoute<dynamic>(builder: (_) => page)),
      ),
    );
  }
}
