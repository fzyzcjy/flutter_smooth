#import "SmoothPlugin.h"
#if __has_include(<smooth/smooth-Swift.h>)
#import <smooth/smooth-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "smooth-Swift.h"
#endif

@implementation SmoothPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSmoothPlugin registerWithRegistrar:registrar];
}
@end
