import 'package:example/example_enter_page_animation/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth_dev/smooth_dev.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => binding.window
    ..physicalSizeTestValue = const Size(100, 150)
    ..devicePixelRatioTestValue = 1);
  tearDown(() => binding.window
    ..clearPhysicalSizeTestValue()
    ..clearDevicePixelRatioTestValue());

  group('golden for animation', () {
    for (final arg in const [
      _GoldenArg(
        name: 'InfinitelyFast',
        listTileCount: 150,
        listTileBuildTime: Duration.zero,
        listTileLayoutTime: Duration.zero,
        recordNumFrames: 22,
      ),
      _GoldenArg(
        // mimic real case
        name: 'Realistic',
        listTileCount: 150,
        listTileBuildTime: Duration(milliseconds: 1),
        listTileLayoutTime: Duration(milliseconds: 5),
        // 150 list tiles, (1+5) ms for one, so need ~54 frames
        recordNumFrames: 60,
      ),
      _GoldenArg(
        name: 'HighEnd',
        listTileCount: 150,
        listTileBuildTime: Duration(microseconds: 300),
        listTileLayoutTime: Duration(milliseconds: 1),
        recordNumFrames: 22,
      ),
    ]) {
      testWidgets(arg.name, (tester) async {
        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
        final timeInfo = TimeInfo();
        final capturer = WindowRenderCapturer.autoDispose();

        await tester.pumpWidget(SmoothParent(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: ExampleEnterPageAnimationPage(
              listTileCount: arg.listTileCount,
              wrapListTile: ({required child}) => SpyBuilder(
                onBuild: () => binding.elapseBlocking(arg.listTileBuildTime,
                    reason: 'ListTile build'),
                onPerformLayout: () => binding.elapseBlocking(
                    arg.listTileLayoutTime,
                    reason: 'ListTile layout'),
                child: ColoredBox(
                  color: Colors.green,
                  child: child,
                ),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('smooth'));

        for (var i = 0; i < arg.recordNumFrames; ++i) {
          await tester.pump(timeInfo.calcPumpDurationAuto());
        }

        await capturer.pack.matchesGoldenFile(tester,
            '../goldens/example_enter_page_animation/${arg.name}/screen');

        debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
      });
    }
  });
}

@immutable
class _GoldenArg {
  final String name;
  final int listTileCount;
  final Duration listTileBuildTime;
  final Duration listTileLayoutTime;
  final int recordNumFrames;

  const _GoldenArg({
    required this.name,
    required this.listTileCount,
    required this.listTileBuildTime,
    required this.listTileLayoutTime,
    required this.recordNumFrames,
  });
}
