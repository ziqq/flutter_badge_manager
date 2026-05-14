import Foundation

#if os(iOS)
import Flutter
import UIKit
import UserNotifications
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif

protocol BadgeWriting {
  func setBadge(_ value: Int)
}

#if os(iOS)
protocol UserNotificationCenterBadgeSetting {
  func setBadgeCount(_ value: Int, completionHandler: ((Error?) -> Void)?)
}

struct SystemUserNotificationCenterBadgeSetter:
  UserNotificationCenterBadgeSetting
{
  func setBadgeCount(
    _ value: Int,
    completionHandler: ((Error?) -> Void)?
  ) {
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(
        value,
        withCompletionHandler: completionHandler
      )
      return
    }

    completionHandler?(nil)
  }
}

protocol ApplicationBadgeSetting {
  func setApplicationIconBadgeNumber(_ value: Int)
}

struct SystemApplicationBadgeSetter: ApplicationBadgeSetting {
  func setApplicationIconBadgeNumber(_ value: Int) {
    UIApplication.shared.applicationIconBadgeNumber = value
  }
}

final class IOSBadgeWriter: BadgeWriting {
  init(
    notificationCenter: UserNotificationCenterBadgeSetting =
      SystemUserNotificationCenterBadgeSetter(),
    application: ApplicationBadgeSetting = SystemApplicationBadgeSetter(),
    supportsModernBadgeAPI: @escaping () -> Bool = {
      if #available(iOS 16.0, *) {
        return true
      }
      return false
    }
  ) {
    self.notificationCenter = notificationCenter
    self.application = application
    self.supportsModernBadgeAPI = supportsModernBadgeAPI
  }

  private let notificationCenter: UserNotificationCenterBadgeSetting
  private let application: ApplicationBadgeSetting
  private let supportsModernBadgeAPI: () -> Bool

  func setBadge(_ value: Int) {
    let writeBadge = {
      self.application.setApplicationIconBadgeNumber(value)

      if self.supportsModernBadgeAPI() {
        self.notificationCenter.setBadgeCount(value) { error in
          if let error {
            NSLog(
              "[flutter_badge_manager_foundation] Failed to persist badge count: %@",
              error.localizedDescription
            )
          }
        }
      }
    }

    if Thread.isMainThread {
      writeBadge()
      return
    }

    DispatchQueue.main.sync(execute: writeBadge)
  }
}
#elseif os(macOS)
final class MacOSBadgeWriter: BadgeWriting {
  func setBadge(_ value: Int) {
    DispatchQueue.main.async {
      let dockTile = NSApplication.shared.dockTile
      dockTile.badgeLabel = value > 0 ? String(value) : nil
    }
  }
}
#endif

/// The iOS and macOS implementation of the Flutter badge manager plugin.
/// This class handles method calls from Flutter to manage app icon badges.
public class FlutterBadgeManagerPlugin: NSObject, FlutterPlugin, FlutterBadgeManagerApi {
  init(badgeWriter: BadgeWriting? = nil) {
    self.badgeWriter = badgeWriter ?? Self.makeBadgeWriter()
  }

  private let badgeWriter: BadgeWriting

  private static func makeBadgeWriter() -> BadgeWriting {
    #if os(iOS)
    return IOSBadgeWriter()
    #elseif os(macOS)
    return MacOSBadgeWriter()
    #endif
  }

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
    FlutterBadgeManagerApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  // Handles method calls from Flutter.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      // iOS and macOS always support badges
      do {
        result(try isSupported())
      } catch let error as PigeonError {
        result(FlutterError(code: error.code, message: error.message, details: error.details))
      } catch {
        result(FlutterError(code: "error", message: error.localizedDescription, details: nil))
      }

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
      do {
        try update(count: Int64(count))
        result(nil)
      } catch let error as PigeonError {
        result(FlutterError(code: error.code, message: error.message, details: error.details))
      } catch {
        result(FlutterError(code: "error", message: error.localizedDescription, details: nil))
      }

    // Remove the badge
    case "remove":
      do {
        try remove()
        result(nil)
      } catch let error as PigeonError {
        result(FlutterError(code: error.code, message: error.message, details: error.details))
      } catch {
        result(FlutterError(code: "error", message: error.localizedDescription, details: nil))
      }

    // Unsupported method
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func isSupported() throws -> Bool? {
    true
  }

  func update(count: Int64) throws {
    guard count >= 0 else {
      throw PigeonError(
        code: "invalid_args",
        message: "Missing non-negative count",
        details: nil
      )
    }

    setBadge(Int(count))
  }

  func remove() throws {
    setBadge(0)
  }

  // Sets the badge count on the app icon.
  private func setBadge(_ value: Int) {
    badgeWriter.setBadge(value)
  }
}