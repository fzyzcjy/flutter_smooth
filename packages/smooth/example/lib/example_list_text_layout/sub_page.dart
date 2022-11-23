import 'package:flutter/material.dart';
import 'package:smooth/smooth.dart';

// NOTE This is used to reproduce [list_text_layout.dart] in Flutter's official
// benchmark, as is requested by @dnfield in #173
class ExampleListTextLayoutSubPage extends StatefulWidget {
  final bool enableSmooth;

  const ExampleListTextLayoutSubPage({super.key, required this.enableSmooth});

  @override
  State<ExampleListTextLayoutSubPage> createState() =>
      ExampleListTextLayoutSubPageState();
}

class ExampleListTextLayoutSubPageState
    extends State<ExampleListTextLayoutSubPage>
    with SingleTickerProviderStateMixin {
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
    return widget.enableSmooth
        ? SmoothBuilder(
            builder: (_, __) => _buildCore(),
            child: const SizedBox(),
          )
        : _buildCore();
  }

  Widget _buildCore() {
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
