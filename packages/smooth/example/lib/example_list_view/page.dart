import 'package:example/example_list_view/sub_page.dart';
import 'package:example/utils/page_utils.dart';
import 'package:flutter/material.dart';

class ExampleListViewPage extends StatelessWidget {
  const ExampleListViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example: ListView'),
      ),
      body: Builder(
        builder: (context) => ListView(
          children: [
            PageUtils.buildRow(
                const ExampleListViewSubPage(enableSmooth: false),
                'Example: Plain'),
            PageUtils.buildRow(const ExampleListViewSubPage(enableSmooth: true),
                'Example: Smooth'),
            const SizedBox(height: 120),
            const Divider(thickness: 1, color: Colors.grey),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4),
              child: Text(
                'Below are not demo, but to debug the implementation',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            PageUtils.buildRow(
                const ExampleListViewSubPage(
                    enableSmooth: false, enableDebugHeader: true),
                'Debug: Plain + DebugHeader'),
            PageUtils.buildRow(
                const ExampleListViewSubPage(
                    enableSmooth: true, enableDebugHeader: true),
                'Debug: Smooth + DebugHeader'),
            PageUtils.buildRow(
                const ExampleListViewSubPage(
                    enableSmooth: true,
                    enableDebugHeader: true,
                    leaveWhenPointerUp: true),
                'Debug: Smooth + LeaveWhenPointerUp'),
            PageUtils.buildRow(
                const ExampleListViewSubPage(
                    enableSmooth: false,
                    enableAlwaysWorkload: false,
                    enableNewItemWorkload: false),
                'Debug: Plain + ZeroWorkload'),
          ],
        ),
      ),
    );
  }
}
