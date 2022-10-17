import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/infra/brake/build_after_previous_build_or_layout.dart';

import '../test_tools/widgets.dart';

void main() {
  group('BuildAfterPreviousLayout should build after previous layout or build',
      () {
    Future<void> _body(
      WidgetTester tester,
      Widget Function(
              {required VoidCallback onPrevious,
              required VoidCallback onSelfBuild})
          buildWidget,
    ) async {
      var previousLayoutCalled = false, selfBuildCalled = false;

      await tester.pumpWidget(buildWidget(
        onPrevious: () {
          expect(previousLayoutCalled, false);
          expect(selfBuildCalled, false);
          previousLayoutCalled = true;
        },
        onSelfBuild: () {
          expect(previousLayoutCalled, true,
              reason: 'when self build, should already previous layout');
          expect(selfBuildCalled, false);
          selfBuildCalled = true;
        },
      ));

      expect(previousLayoutCalled, true);
      expect(selfBuildCalled, true);
    }

    for (final layoutOrBuild in _LayoutOrBuild.values) {
      group('consider ${layoutOrBuild.name}', () {
        Widget _buildPreviousWidget(VoidCallback onPrevious) {
          switch (layoutOrBuild) {
            case _LayoutOrBuild.layout:
              return SpyRenderObjectWidget(onPerformLayout: onPrevious);
            case _LayoutOrBuild.build:
              return SpyStatefulWidget(onBuild: onPrevious);
          }
        }

        testWidgets('when previous is simple widget', (tester) async {
          await _body(
            tester,
            ({required onPrevious, required onSelfBuild}) => Column(
              children: [
                _buildPreviousWidget(onPrevious),
                BuildAfterPreviousBuildOrLayout(
                    builder: (_) => SpyStatefulWidget(onBuild: onSelfBuild)),
              ],
            ),
          );
        });

        testWidgets('when previous is wrapped within LayoutBuilder',
            (tester) async {
          await _body(
            tester,
            ({required onPrevious, required onSelfBuild}) => Column(
              children: [
                LayoutBuilder(
                    builder: (_, __) => _buildPreviousWidget(onPrevious)),
                BuildAfterPreviousBuildOrLayout(
                    builder: (_) => SpyStatefulWidget(onBuild: onSelfBuild)),
              ],
            ),
          );
        });

        testWidgets('when previous and self are in ListView', (tester) async {
          await _body(
            tester,
            ({required onPrevious, required onSelfBuild}) => MaterialApp(
              home: ListView.builder(
                itemCount: 2,
                itemBuilder: (_, index) {
                  switch (index) {
                    case 0:
                      return _buildPreviousWidget(onPrevious);
                    case 1:
                      return BuildAfterPreviousBuildOrLayout(
                          builder: (_) =>
                              SpyStatefulWidget(onBuild: onSelfBuild));
                    default:
                      throw Exception;
                  }
                },
              ),
            ),
          );
        });
      });
    }
  });
}

enum _LayoutOrBuild { layout, build }
