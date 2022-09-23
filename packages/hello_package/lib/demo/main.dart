import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var secondPageVisible = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          _buildFirstPage(),
          if (secondPageVisible) _buildSecondPage(),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Preempt for 60FPS')),
        body: Center(
          child: TextButton(
            onPressed: () => setState(() => secondPageVisible = true),
            child: const Text('Enter second page'),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SecondPage'),
          leading: IconButton(
            onPressed: () => setState(() => secondPageVisible = false),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: const ComplexWidget(),
      ),
    );
  }
}

class ComplexWidget extends StatelessWidget {
  const ComplexWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // @dnfield's suggestion - a lot of text
    // https://github.com/flutter/flutter/issues/101227#issuecomment-1247641562
    return Material(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: Column(
          children: List<Widget>.generate(30, (int index) {
            return SizedBox(
              height: 24,
              child: ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircleAvatar(
                    child: Text('G$index'),
                  ),
                ),
                title: Text(
                  'Foo contact from $index-th local contact' * 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 5),
                ),
                subtitle: Text('+91 88888 8800$index'),
              ),
            );
          }),
        ),
      ),
    );
  }
}
