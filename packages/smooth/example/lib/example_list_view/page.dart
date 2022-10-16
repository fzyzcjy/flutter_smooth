import 'package:example/example_list_view/sub_page.dart';
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
            _buildItem(const ExampleListViewSubPage(enableSmooth: false),
                'Example: Plain'),
            _buildItem(const ExampleListViewSubPage(enableSmooth: true),
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
            _buildItem(
                const ExampleListViewSubPage(
                    enableSmooth: false, enableDebugHeader: true),
                'Debug: Plain + DebugHeader'),
            _buildItem(
                const ExampleListViewSubPage(
                    enableSmooth: true, enableDebugHeader: true),
                'Debug: Smooth + DebugHeader'),
            _buildItem(
                const ExampleListViewSubPage(
                    enableSmooth: true,
                    enableDebugHeader: true,
                    leaveWhenPointerUp: true),
                'Debug: Smooth + LeaveWhenPointerUp'),
            _buildItem(
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
