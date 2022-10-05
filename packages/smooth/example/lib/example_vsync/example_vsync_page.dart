import 'package:flutter/material.dart';

class ExampleVsyncPage extends StatefulWidget {
  const ExampleVsyncPage({super.key});

  @override
  State<ExampleVsyncPage> createState() => _ExampleVsyncPageState();
}

class _ExampleVsyncPageState extends State<ExampleVsyncPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example: Vsync'),
      ),
      body: TODO,
    );
  }
}
