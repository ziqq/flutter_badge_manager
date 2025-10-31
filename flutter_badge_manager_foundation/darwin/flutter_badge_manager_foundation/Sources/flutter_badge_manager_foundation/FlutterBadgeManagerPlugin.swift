import Foundation

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

/// The iOS and macOS implementation of the Flutter badge manager plugin.
/// This class handles method calls from Flutter to manage app icon badges.
public class FlutterBadgeManagerPlugin: NSObject, FlutterPlugin {

  // Registers the plugin with the Flutter framework.
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(iOS)
    let messenger = registrar.messenger()
    #else
    let messenger = registrar.messenger
    #endif
    let channel = FlutterMethodChannel(
      name: "github.com/ziqq/flutter_badge_manager",
      binaryMessenger: messenger
    )
    let instance = FlutterBadgeManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // Handles method calls from Flutter.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      // iOS and macOS always support badges
      result(true)

    // Update the badge count
    case "update":
      guard
        let args = call.arguments as? [String: Any],
        let count = args["count"] as? Int,
        count >= 0
      else {
        result(FlutterError(code: "invalid_args", message: "Missing non-negative count", details: nil))
        return
      }
      setBadge(count)
      result(nil)

    // Remove the badge
    case "remove":
      setBadge(0)
      result(nil)

    // Unsupported method
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Sets the badge count on the app icon.
  private func setBadge(_ value: Int) {
    #if os(iOS)
    // Update the iOS app icon badge number
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = value
    }
    #else
    // Update the macOS dock tile badge label
    DispatchQueue.main.async {
      let dockTile = NSApplication.shared.dockTile
      dockTile.badgeLabel = value > 0 ? String(value) : nil
    }
    #endif
  }
}