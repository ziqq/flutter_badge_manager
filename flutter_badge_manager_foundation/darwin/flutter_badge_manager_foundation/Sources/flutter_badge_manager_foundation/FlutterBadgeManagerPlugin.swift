import Foundation

#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

public class FlutterBadgeManagerPlugin: NSObject, FlutterPlugin {

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

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      // И iOS, и macOS поддерживают badge.
      result(true)

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

    case "remove":
      setBadge(0)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setBadge(_ value: Int) {
    #if os(iOS)
    DispatchQueue.main.async {
      UIApplication.shared.applicationIconBadgeNumber = value
    }
    #else
    DispatchQueue.main.async {
      let dockTile = NSApplication.shared.dockTile
      dockTile.badgeLabel = value > 0 ? String(value) : nil
    }
    #endif
  }
}