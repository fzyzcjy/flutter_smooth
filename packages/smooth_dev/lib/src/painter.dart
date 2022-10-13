import 'dart:ui';

// ref [flutter/examples/layers/raw/hello_world.dart]
Scene buildSceneFromPainter(Size size, void Function(Canvas) painter) {
  final paintBounds = Offset.zero & size;

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, paintBounds);

  painter(canvas);

  final picture = recorder.endRecording();

  final sceneBuilder = SceneBuilder()..addPicture(Offset.zero, picture);

  return sceneBuilder.build();
}

Image buildImageFromPainter(Size size, void Function(Canvas) painter) {
  final scene = buildSceneFromPainter(size, painter);
  return scene.toImageSync(size.width.round(), size.height.round());
}
