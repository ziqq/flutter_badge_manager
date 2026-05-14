/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 14 May 2026
 */

import Foundation

#if !canImport(Flutter) && !canImport(FlutterMacOS)
public protocol FlutterPlugin: AnyObject {}
public protocol UIApplicationDelegate {}
public protocol FlutterTextureRegistry {}

public typealias FlutterResult = (Any?) -> Void
public typealias FlutterBinaryReply = (Data?) -> Void
public typealias FlutterBinaryMessageHandler = (Data?, FlutterBinaryReply?) -> Void

public final class FlutterMethodCall {
  public init(method: String, arguments: Any?) {
    self.method = method
    self.arguments = arguments
  }

  public let method: String
  public let arguments: Any?
}

public final class FlutterMethodChannel {
  public init(name: String, binaryMessenger: FlutterBinaryMessenger) {
    self.name = name
    self.binaryMessenger = binaryMessenger
  }

  public let name: String
  public let binaryMessenger: FlutterBinaryMessenger
}

public final class FlutterError: Error {
  public init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  public let code: String
  public let message: String?
  public let details: Any?
}

public let FlutterMethodNotImplemented = "FlutterMethodNotImplemented"

public protocol FlutterBinaryMessenger: AnyObject {
  func send(onChannel channel: String, message: Data?)
  func send(
    onChannel channel: String,
    message: Data?,
    binaryReply callback: FlutterBinaryReply?
  )
  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler?
  )
}

public protocol FlutterPluginRegistrar: AnyObject {
  var messenger: FlutterBinaryMessenger { get }
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel)
  func textures() -> FlutterTextureRegistry
  func add(_ applicationDelegate: FlutterPlugin & UIApplicationDelegate)
  func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar
  func publish(_ value: NSObject)
  func lookupKey(for asset: String) -> String
  func lookupKey(for asset: String, fromPackage package: String) -> String
  func register(_ plugin: FlutterPlugin & NSObjectProtocol)
}

public final class PigeonError: Error {
  public init(code: String, message: String?, details: Any?) {
    self.code = code
    self.message = message
    self.details = details
  }

  public let code: String
  public let message: String?
  public let details: Any?

  public var localizedDescription: String {
    "PigeonError(code: \(code), message: \(message ?? "<nil>"), details: \(details ?? "<nil>"))"
  }
}

protocol FlutterBadgeManagerApi {
  func isSupported() throws -> Bool?
  func update(count: Int64) throws
  func remove() throws
}

final class FlutterBadgeManagerApiSetup {
  static func setUp(
    binaryMessenger: FlutterBinaryMessenger,
    api: FlutterBadgeManagerApi?,
    messageChannelSuffix: String = ""
  ) {
    let channelSuffix = messageChannelSuffix.isEmpty ? "" : ".\(messageChannelSuffix)"
    let channels = [
      "dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi.isSupported\(channelSuffix)",
      "dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi.update\(channelSuffix)",
      "dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi.remove\(channelSuffix)",
    ]

    guard api != nil else {
      for channel in channels {
        binaryMessenger.setMessageHandlerOnChannel(channel, binaryMessageHandler: nil)
      }
      return
    }

    for channel in channels {
      binaryMessenger.setMessageHandlerOnChannel(channel) { _, reply in
        reply?(nil)
      }
    }
  }
}
#endif
