import 'package:flutter/material.dart';

class ExperimentListView extends StatefulWidget {
  const ExperimentListView({super.key});

  @override
  State<ExperimentListView> createState() => _ExperimentListViewState();
}

class _ExperimentListViewState extends State<ExperimentListView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView.builder(
          itemBuilder: (_, index) => ListTile(
            title: Text('i=$index'),
          ),
        ),
      ),
    );
  }
}
