// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

class ComplexLongColumn extends StatelessWidget {
  const ComplexLongColumn({super.key});

  @override
  Widget build(BuildContext context) {
    // const N = 30;
    // const N = 60; // make it big to see jank clearly
    const N = 150; // make it big to see jank clearly
    // const N = 1000; // for debug

    // do not let semantics confuse the metrics. b/c we are having a huge
    // amount of text in this demo, while in realworld never has that
    return ExcludeSemantics(
      // @dnfield's suggestion - a lot of text
      // https://github.com/flutter/flutter/issues/101227#issuecomment-1247641562
      child: Material(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: Column(
            children: List<Widget>.generate(N, (index) {
              return SmoothPreemptPoint(
                child: ComplexListTile(index: index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ComplexListTile extends StatelessWidget {
  final int index;

  const ComplexListTile({super.key, required this.index});

  static void Function(int index)? onBuild;

  // static const _textRepeat = 5;
  static const _textRepeat = 1;

  @override
  Widget build(BuildContext context) {
    onBuild?.call(index);
    TODO_need_on_layout;

    return SizedBox(
      height: 12,
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
          'Foo contact from $index-th local contact' * _textRepeat,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 5),
        ),
        subtitle: Text('+91 88888 8800$index'),
      ),
    );
  }
}
