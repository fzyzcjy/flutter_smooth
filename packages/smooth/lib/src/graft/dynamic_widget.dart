import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that has dynamic number of children
// ref [SliverList], i.e. [SliverMultiBoxAdaptorWidget]
abstract class DynamicWidget extends RenderObjectWidget {
  const DynamicWidget({super.key});

  @override
  DynamicElement createElement() => DynamicElement(this);

  @override
  RenderDynamic createRenderObject(BuildContext context);
}

// ref [RenderSliverBoxChildManager]
abstract class RenderDynamicChildManager {
  void createChild(int index, {required RenderBox? after});

  void removeChild(RenderBox child);
}

// ref [SliverMultiBoxAdaptorElement]
class DynamicElement extends RenderObjectElement
    implements RenderDynamicChildManager {
  DynamicElement(super.widget);

  @override
  void createChild(int index, {required RenderBox? after}) {
    TODO;
  }

  @override
  void removeChild(RenderBox child) {
    TODO;
  }
}

// ref [RenderSliverMultiBoxAdaptor]
abstract class RenderDynamic extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SliverMultiBoxAdaptorParentData> {
  RenderDynamic({required this.childManager});

  // ref [RenderSliverMultiBoxAdaptor]
  final RenderDynamicChildManager childManager;

// TODO
}
