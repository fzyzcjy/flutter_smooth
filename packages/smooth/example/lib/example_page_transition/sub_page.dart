import 'package:example/utils/complex_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smooth/smooth.dart';

class ExamplePageTransitionSubPage extends StatefulWidget {
  final bool enableSmooth;
  final int listTileCount;
  final WidgetWrapper? wrapListTile;

  const ExamplePageTransitionSubPage({
    super.key,
    required this.enableSmooth,
    this.listTileCount = 150,
    this.wrapListTile,
  });

  @override
  State<ExamplePageTransitionSubPage> createState() =>
      _ExamplePageTransitionSubPageState();
}

class _ExamplePageTransitionSubPageState
    extends State<ExamplePageTransitionSubPage> {
  var tapped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Page')),
      body: Builder(
        builder: (context) => Center(
          child: GestureDetector(
            onTap: () => _handleTap(context),
            child: Text(
              tapped ? 'Tapped, page is loading' : 'Tap me',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    setState(() {
      tapped = true;
    });

    // wait a frame, such that we can tell reader it is tapped
    // even for the janky non-smooth case
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // TODO use our page route
      Navigator.push<dynamic>(
        context,
        _buildPageRoute(
          builder: (_) => _SecondPage(
            listTileCount: widget.listTileCount,
            wrapListTile: widget.wrapListTile,
          ),
        ),
      );
    });
  }

  PageRoute<dynamic> _buildPageRoute({required WidgetBuilder builder}) {
    if (widget.enableSmooth) {
      return SmoothMaterialPageRoute<dynamic>(builder: builder);

      // // TODO change it to "material" page route
      // // currently mimic https://docs.flutter.dev/cookbook/animation/page-route-animation
      // return SmoothPageRouteBuilder<dynamic>(
      //   pageBuilder: (context, _, __) => builder(context),
      //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //     const begin = Offset(0.0, 1.0);
      //     const end = Offset.zero;
      //     const curve = Curves.ease;
      //
      //     final tween =
      //         Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      //
      //     return SlideTransition(
      //       position: animation.drive(tween),
      //       child: child,
      //     );
      //   },
      // );
    } else {
      return MaterialPageRoute<dynamic>(builder: builder);
    }
  }
}

class _SecondPage extends StatefulWidget {
  final int listTileCount;
  final WidgetWrapper? wrapListTile;

  const _SecondPage({
    required this.listTileCount,
    required this.wrapListTile,
  });

  @override
  State<_SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<_SecondPage> {
  var placeholder = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // This hack is because [ModalRoute.offstage] needs one extra frame
      // to be updated to false. We should find other workarounds later
      // so we can remove this extra latency.
      // https://github.com/fzyzcjy/flutter_smooth/issues/127#issuecomment-1279972708
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => placeholder = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Page')),
      body: placeholder
          // the placeholder to show when the complex widget is loading
          ? Container(
              color: Colors.white,
            )
          : ComplexWidget(
              listTileCount: widget.listTileCount,
              wrapListTile: widget.wrapListTile,
            ),
    );
  }
}
