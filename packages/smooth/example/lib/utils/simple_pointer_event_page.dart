import 'package:flutter/material.dart';

class SimplePointerEventPage extends StatefulWidget {
  const SimplePointerEventPage({super.key});

  @override
  State<SimplePointerEventPage> createState() => _SimplePointerEventPageState();
}

class _SimplePointerEventPageState extends State<SimplePointerEventPage> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimplePointerEventPage'),
      ),
      body: Listener(
        onPointerMove: (_) => setState(() => count++),
        child: ColoredBox(
          color: Colors.white,
          child: Center(
            child: Text(
              '#event=$count',
              style: const TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}
