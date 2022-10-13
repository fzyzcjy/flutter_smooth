import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/host_api/messages.dart',
  javaOut: 'android/src/main/java/com/cjy/smooth/Messages.java',
  objcHeaderOut: 'ios/Classes/messages.h',
  objcSourceOut: 'ios/Classes/messages.m',
  javaOptions: JavaOptions(
    package: 'com.cjy.smooth',
  ),
  objcOptions: ObjcOptions(
    prefix: 'CS',
  ),
  dartOptions: DartOptions(copyrightHeader: [
    'ignore_for_file: avoid-non-null-assertion, prefer_constructors_over_static_methods'
  ]),
))
@HostApi()
abstract class SmoothHostApi {
  int pointerEventDateTimeDiffTimeStamp();
}
