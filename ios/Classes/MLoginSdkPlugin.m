#import "MLoginSdkPlugin.h"
#if __has_include(<m_login_sdk/m_login_sdk-Swift.h>)
#import <m_login_sdk/m_login_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "m_login_sdk-Swift.h"
#endif

@implementation MLoginSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMLoginSdkPlugin registerWithRegistrar:registrar];
}
@end
