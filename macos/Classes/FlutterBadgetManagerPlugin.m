#import "FlutterBadgetManagerPlugin.h"

@implementation FlutterBadgetManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"ziqq/flutter_badge_manager"
                                  binaryMessenger:[registrar messenger]];
  FlutterBadgetManagerPlugin *instance = [[FlutterBadgetManagerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call
                  result:(FlutterResult)result {
  NSLog(@"%@", call.method);
  if ([@"update" isEqualToString:call.method]) {
    NSDictionary *args = call.arguments;
    NSNumber *count = [args objectForKey:@"count"];
    [NSApp dockTile].badgeLabel = [count stringValue];
    result(nil);
  } else if ([@"remove" isEqualToString:call.method]) {
    [NSApp dockTile].badgeLabel = nil;
    result(nil);
  } else if ([@"isSupported" isEqualToString:call.method]) {
    result(@YES);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
