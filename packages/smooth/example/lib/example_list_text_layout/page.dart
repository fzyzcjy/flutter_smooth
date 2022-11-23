import 'package:example/example_list_text_layout/sub_page.dart';
import 'package:example/utils/page_utils.dart';
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
            const Text(
              'Please look at timeline tracing to see the effects of smooth, '
              'since this is a reproduction to Flutter list_text_layout '
              'and thus do *not* have any visual signal showing it is smoother',
            ),
            PageUtils.buildRow(
                const ExampleListTextLayoutSubPage(enableSmooth: false),
                'Example: Plain'),
            PageUtils.buildRow(
                const ExampleListTextLayoutSubPage(enableSmooth: true),
                'Example: Smooth'),
          ],
        ),
      ),
    );
  }
}
