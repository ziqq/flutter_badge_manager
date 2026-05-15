import Foundation

#if os(iOS)
#if canImport(Flutter)
import Flutter
#endif
import UIKit
import UserNotifications
#elseif os(macOS)
#if canImport(FlutterMacOS)
import FlutterMacOS
#endif
import AppKit
#endif

#if os(iOS)
protocol UserNotificationCenterBadgeSetting {
  func setBadgeCount(_ value: Int, completionHandler: ((Error?) -> Void)?)
}

protocol UserNotificationCenterSettingsReading {
  func getNotificationSettings(
    completionHandler: @escaping (UNNotificationSettings) -> Void
  )
}

struct SystemUserNotificationCenterBadgeSetter: UserNotificationCenterBadgeSetting {
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

struct SystemUserNotificationCenterSettingsReader: UserNotificationCenterSettingsReading {
  func getNotificationSettings(
    completionHandler: @escaping (UNNotificationSettings) -> Void
  ) {
    UNUserNotificationCenter.current().getNotificationSettings(
      completionHandler: completionHandler
    )
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

protocol BadgeWriter {
  func setBadge(_ value: Int)
}

final class IOSBadgeWriter: BadgeWriter {
  init(
    notificationSettingsReader: UserNotificationCenterSettingsReading = SystemUserNotificationCenterSettingsReader(),
    notificationCenter: UserNotificationCenterBadgeSetting = SystemUserNotificationCenterBadgeSetter(),
    application: ApplicationBadgeSetting = SystemApplicationBadgeSetter(),
    supportsModernBadgeAPI: @escaping () -> Bool = {
      if #available(iOS 16.0, *) {
        return true
      }
      return false
    }
  ) {
    self.application = application
    self.notificationCenter = notificationCenter
    self.supportsModernBadgeAPI = supportsModernBadgeAPI
    self.notificationSettingsReader = notificationSettingsReader
  }

  private let notificationSettingsReader: UserNotificationCenterSettingsReading
  private let notificationCenter: UserNotificationCenterBadgeSetting
  private let application: ApplicationBadgeSetting
  private let supportsModernBadgeAPI: () -> Bool

  func setBadge(_ value: Int) {
    applyBadge(value)
  }

  private func applyBadge(_ value: Int) {
    let writeBadge = {
      self.application.setApplicationIconBadgeNumber(value)

      if self.supportsModernBadgeAPI() {
        self.notificationSettingsReader.getNotificationSettings { settings in
          guard settings.badgeSetting == .enabled else {
            return
          }

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
    }

    if Thread.isMainThread {
      writeBadge()
      return
    }

    DispatchQueue.main.sync(execute: writeBadge)
  }
}

#elseif os(macOS)
final class MacOSBadgeWriter: BadgeWriter {
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
  init(badgeWriter: BadgeWriter? = nil) {
    self.badgeWriter = badgeWriter ?? Self.makeBadgeWriter()
  }

  private let badgeWriter: BadgeWriter

  private static func makeBadgeWriter() -> BadgeWriter {
    #if os(iOS)
    return IOSBadgeWriter()
    #elseif os(macOS)
    return MacOSBadgeWriter()
    #endif
  }

  private static func resolveMessenger(
    from registrar: FlutterPluginRegistrar
  ) -> FlutterBinaryMessenger {
    #if os(iOS)
    return registrar.messenger()
    #else
    return registrar.messenger
    #endif
  }

  // MARK: - Registers the plugin with the Flutter framework.
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = resolveMessenger(from: registrar)
    let channel = FlutterMethodChannel(
      name: "github.com/ziqq/flutter_badge_manager",
      binaryMessenger: messenger
    )
    let instance = FlutterBadgeManagerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    FlutterBadgeManagerApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  // MARK: - FlutterPlugin conformance. Handles method calls from Flutter.
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    // Check if badge management is supported on the current platform
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

  // MARK: - isSupported, update, and remove implementations
  func isSupported() throws -> Bool? {
    true
  }

  // MARK: - update the badge from the app icon. Throws if the count is invalid (e.g., negative).
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

  // MARK: - remove the badge from the app icon.
  func remove() throws {
    setBadge(0)
  }

  // MARK: - Private helper to set the badge count using the injected badge writer.
  private func setBadge(_ value: Int) {
    badgeWriter.setBadge(value)
  }
}