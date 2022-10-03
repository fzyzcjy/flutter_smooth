import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/graft/adapter_in_auxiliary_tree.dart';
import 'package:smooth/src/graft/builder.dart';
import 'package:smooth/src/service_locator.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  // TODO move
  // TODO should not let [graft] module know [ServiceLocator]?
  Finder.rootElements = () => [
        WidgetsBinding.instance.renderViewElement!,
        ...ServiceLocator.instance.auxiliaryTreeRegistry.trees
            .map((tree) => tree.element),
      ];

  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
  binding.window.setUpTearDown(
    physicalSizeTestValue: const Size(50, 100),
    devicePixelRatioTestValue: 1,
  );

  group('pointer events', () {
    for (final touchable in _Touchable.values) {
      group('touchable=${touchable.name}', () {
        Future<void> _body(
          WidgetTester tester, {
          required Widget Function(VoidCallback onTap) buildChild,
        }) async {
          final timeInfo = TimeInfo();

          var tapped = false;

          // TODO remove this "set state" hack, after #5955 fixed
          late StateSetter outerWidgetSetState;
          await tester.pumpWidget(StatefulBuilder(builder: (_, setState) {
            outerWidgetSetState = setState;
            return SmoothScope(child: buildChild(() => tapped = true));
          }));

          expect(tapped, false);

          await tester.tap(find.byType(touchable.widgetType));
          outerWidgetSetState(() {}); // temporary hack #5955
          await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

          expect(tapped, true);
        }

        testWidgets('touchable in main tree parent', (tester) async {
          await _body(
            tester,
            buildChild: (onTap) => touchable.build(
              onTap: onTap,
              child: GraftBuilder<int>(
                auxiliaryTreeBuilder: (_) =>
                    const GraftAdapterInAuxiliaryTree(slot: 42),
                mainTreeChildBuilder: (_, slot) =>
                    Container(color: Colors.blue),
              ),
            ),
          );
        });

        testWidgets('touchable in aux tree', (tester) async {
          await _body(
            tester,
            buildChild: (onTap) => GraftBuilder<int>(
              auxiliaryTreeBuilder: (_) => touchable.build(
                onTap: onTap,
                child: const GraftAdapterInAuxiliaryTree(slot: 42),
              ),
              mainTreeChildBuilder: (_, slot) => Container(color: Colors.blue),
            ),
          );
        });

        testWidgets('touchable in main tree child', (tester) async {
          await _body(
            tester,
            buildChild: (onTap) => GraftBuilder<int>(
              auxiliaryTreeBuilder: (_) =>
                  const GraftAdapterInAuxiliaryTree(slot: 42),
              mainTreeChildBuilder: (_, slot) => touchable.build(
                onTap: onTap,
                child: Container(color: Colors.blue),
              ),
            ),
          );
        });
      });
    }

    // TODO when both aux tree and main tree child are touchable etc #5957
  });

  testWidgets('simplest', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
    final timeInfo = TimeInfo();
    final capturer = WindowRenderCapturer.autoDispose();

    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
    ];

    // TODO remove this "set state" hack, after #5955 fixed
    late StateSetter outerWidgetSetState;
    await tester.pumpWidget(StatefulBuilder(builder: (_, setState) {
      outerWidgetSetState = setState;
      return SmoothScope(
        // only for debug
        // child: Directionality(
        //   textDirection: TextDirection.ltr,
        //   child: ListView.builder(
        //     itemCount: 3,
        //     // NOTE deliberately disable it to test accurately
        //     cacheExtent: 0,
        //     itemBuilder: (_, index) {
        //       debugPrint('ListView.itemBuilder called ($index)');
        //       return Container(height: 60, color: colors[index]);
        //     },
        //   ),
        // ),
        child: GraftBuilder<int>(
          auxiliaryTreeBuilder: (_) => Directionality(
            textDirection: TextDirection.ltr,
            child: ListView.builder(
              itemCount: 3,
              // NOTE deliberately disable it to test accurately
              cacheExtent: 0,
              itemBuilder: (_, index) {
                debugPrint('ListView.itemBuilder called ($index)');
                return GraftAdapterInAuxiliaryTree(slot: index);
              },
            ),
          ),
          mainTreeChildBuilder: (_, slot) => Container(
            height: 60,
            color: colors[slot],
          ),
        ),
      );
    }));
    await capturer
        .expectAndReset(tester, expectTestFrameNumber: 2, expectImages: [
      await tester.createScreenImage((im) => im
        ..fillRect(const Rectangle(0, 0, 50, 60), colors[0])
        ..fillRect(const Rectangle(0, 60, 50, 40), colors[1])),
    ]);

    await tester.drag(find.byType(Scrollable), const Offset(0, -50));
    outerWidgetSetState(() {}); // temporary hack #5955
    await tester.pump(timeInfo.calcPumpDuration(smoothFrameIndex: 1));

    await capturer
        .expectAndReset(tester, expectTestFrameNumber: 3, expectImages: [
      await tester.createScreenImage((im) => im
        ..fillRect(const Rectangle(0, 0, 50, 10), colors[0])
        ..fillRect(const Rectangle(0, 10, 50, 60), colors[1])
        ..fillRect(const Rectangle(0, 70, 50, 30), colors[2])),
    ]);

    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
  });
}

enum _Touchable {
  listener(Listener),
  gestureDetector(GestureDetector);

  const _Touchable(this.widgetType);

  final Type widgetType;

  Widget build({required VoidCallback onTap, required Widget child}) {
    switch (this) {
      case _Touchable.listener:
        return Listener(onPointerDown: (_) => onTap(), child: child);
      case _Touchable.gestureDetector:
        return GestureDetector(onTap: onTap, child: child);
    }
  }
}
