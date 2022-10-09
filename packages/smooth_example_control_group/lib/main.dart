import 'package:flutter/material.dart';
import 'package:smooth_example_control_group/experiment_list_view.dart';
import 'package:smooth_example_control_group/experiment_rasterizer/experiment_rasterizer.dart';

void main() {
  experimentRasterizerStandard();

  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example (Control Group)'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text('ListView'),
              onTap: () => Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                      builder: (_) => const ExperimentListView())),
            ),
          ],
        ),
      ),
    );
  }
}
