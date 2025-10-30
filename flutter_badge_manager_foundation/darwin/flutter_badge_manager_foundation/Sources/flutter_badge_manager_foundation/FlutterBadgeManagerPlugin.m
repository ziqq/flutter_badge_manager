#import "FlutterBadgeManagerPlugin.h"
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>
#endif

@implementation FlutterBadgeManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"github.com/ziqq/flutter_badge_manager"
            binaryMessenger:[registrar messenger]];
  FlutterBadgeManagerPlugin* instance = [[FlutterBadgeManagerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

// iOS only: request notification permissions for badge usage (deployment target >= iOS 13).
- (void)enableNotificationsIfMobile {
#if !TARGET_OS_OSX
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              // We ignore result; badge usually works even if not granted (will just not show alerts).
                          }];
#endif
}

// Shared badge setter: ensures main-thread execution and argument sanitation.
- (void)setBadgeNumber:(NSNumber *)count result:(FlutterResult)result {
    if (count == nil) {
        result([FlutterError errorWithCode:@"invalid_args" message:@"Missing 'count' argument" details:nil]);
        return;
    }
    NSInteger value = [count integerValue];
    if (value < 0) {
        result([FlutterError errorWithCode:@"invalid_args" message:@"Badge count must be >= 0" details:@{ @"count": count }]);
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
#if TARGET_OS_OSX
        NSDockTile *dockTile = [NSApp dockTile];
        dockTile.badgeLabel = (value > 0) ? [NSString stringWithFormat:@"%ld", (long)value] : nil;
#else
        [self enableNotificationsIfMobile];
        [UIApplication sharedApplication].applicationIconBadgeNumber = value;
#endif
        result(nil);
    });
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"update" isEqualToString:call.method]) {
        NSNumber *count = [call.arguments objectForKey:@"count"];
        [self setBadgeNumber:count result:result];
    } else if ([@"remove" isEqualToString:call.method]) {
        [self setBadgeNumber:@0 result:result];
    } else if ([@"isSupported" isEqualToString:call.method]) {
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
