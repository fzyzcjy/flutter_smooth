import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

class ExampleListTextLayoutSubPage extends StatelessWidget {
  final bool enableSmooth;

  const ExampleListTextLayoutSubPage({super.key, required this.enableSmooth});

  @override
  Widget build(BuildContext context) {
    return enableSmooth
        ? SmoothBuilder(
            builder: (context, child) => const _Body(),
            child: const SizedBox.expand(),
          )
        : const _Body();
  }
}

// NOTE This is used to reproduce [list_text_layout.dart] in Flutter's official
// benchmark, as is requested by @dnfield in #173
class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  bool _showText = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showText = !_showText;
          });
          _controller
            ..reset()
            ..forward();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: double.infinity,
          child: !_showText
              ? Container()
              : Column(
                  children: List<Widget>.generate(9, (int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('G$index'),
                      ),
                      title: SmoothLayoutPreemptPointWidget(
                        child: Text(
                          'Foo contact from $index-th local contact',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      subtitle: SmoothLayoutPreemptPointWidget(
                        child: Text('+91 88888 8800$index'),
                      ),
                    );
                  }),
                ),
        ),
      ),
    );
  }
}
