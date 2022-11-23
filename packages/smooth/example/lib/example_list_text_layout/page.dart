import 'package:example/example_list_text_layout/sub_page.dart';
import 'package:flutter/material.dart';

class ExampleListTextLayoutPage extends StatelessWidget {
  const ExampleListTextLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example: Page transition')),
      body: Builder(
        builder: (context) => ListView(
          children: [
            _buildItem(const ExampleListTextLayoutSubPage(enableSmooth: false),
                'Example: Plain'),
            _buildItem(const ExampleListTextLayoutSubPage(enableSmooth: true),
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
