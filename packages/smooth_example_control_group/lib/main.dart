import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth_example_control_group/experiment_list_view.dart';

void main() {
  // experimentRasterizerStandard();
  // experimentRasterizerTwoRenderZeroRender();
  // experimentRasterizerAnotherTwoRenderZeroRender();
  // experimentRasterizerTwoRenderZeroRenderThirdExample();
  // experimentRasterizerTwoRenderZeroRenderFourthExample();
  runApp(const MyApp());
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
        body: Builder(
          builder: (context) => ListView(
            children: [
              ListTile(
                title: const Text('ListView'),
                onTap: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (_) => const ExperimentListView())),
              ),
              ListTile(
                title: const Text('ListView'),
                onTap: () => Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (_) => const ExperimentFullScreenColor())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExperimentFullScreenColor extends StatefulWidget {
  const ExperimentFullScreenColor({Key? key}) : super(key: key);

  @override
  State<ExperimentFullScreenColor> createState() =>
      _ExperimentFullScreenColorState();
}

class _ExperimentFullScreenColorState extends State<ExperimentFullScreenColor> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    count++;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });

    const colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    return Scaffold(
      body: Container(
        color: colors[count % colors.length],
      ),
    );
  }
}
