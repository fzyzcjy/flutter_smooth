// ignore_for_file: avoid_print

import 'package:example/example_list_view/page.dart';
import 'package:example/example_page_transition/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

void main() {
  SmoothWidgetsFlutterBinding.ensureInitialized();
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [ExcludeSemantics], because our demo contains a ton of text, much
    // more than normal app
    return ExcludeSemantics(
      child: SmoothParent(
        child: MaterialApp(
          home: _buildHome(),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      appBar: AppBar(title: const Text('FlutterSmooth Demo')),
      body: ListView(
        children: [
          _buildItem(const ExampleListViewPage(), 'Example: ListView'),
          _buildItem(
              const ExamplePageTransitionPage(), 'Example: Page transition'),
        ],
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
