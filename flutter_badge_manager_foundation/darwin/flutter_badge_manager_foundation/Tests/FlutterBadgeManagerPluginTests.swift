import XCTest
#if os(iOS)
import Flutter
#elseif os(macOS)
import FlutterMacOS
#endif
@testable import flutter_badge_manager_foundation

final class FlutterBadgeManagerPluginTests: XCTestCase {

    private class DummyMessenger: NSObject, FlutterBinaryMessenger {
        var lastChannel: String?
        var lastMessage: Data?
        var handlers: [String: FlutterBinaryMessageHandler] = [:]

        func send(onChannel channel: String, message: Data?) {
            lastChannel = channel
            lastMessage = message
        }

        func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
            lastChannel = channel
            lastMessage = message
            callback?(nil)
        }

        func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) {
            handlers[channel] = handler
        }
    }

    private class DummyRegistrar: NSObject, FlutterPluginRegistrar {
        let messenger: DummyMessenger
        init(messenger: DummyMessenger) { self.messenger = messenger }
        func messenger() -> FlutterBinaryMessenger { messenger }
        func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
        func textures() -> FlutterTextureRegistry { fatalError("Not needed") }
        func add(_ applicationDelegate: FlutterPlugin & UIApplicationDelegate) {}
        func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar { self }
        func publish(_ value: NSObject) {}
        func lookupKey(for asset: String) -> String { asset }
        func lookupKey(for asset: String, fromPackage package: String) -> String { asset }
        func register(_ plugin: FlutterPlugin & NSObjectProtocol) {}
    }

    func testRegisterCreatesChannel() {
        let messenger = DummyMessenger()
        let registrar = DummyRegistrar(messenger: messenger)
        FlutterBadgeManagerPlugin.register(with: registrar)
        XCTAssertNotNil(
            messenger.handlers["dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi.isSupported"],
            "Pigeon isSupported handler should be installed"
        )
        XCTAssertNotNil(
            messenger.handlers["dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi.update"],
            "Pigeon update handler should be installed"
        )
        XCTAssertNotNil(
            messenger.handlers["dev.flutter.pigeon.flutter_badge_manager_foundation.FlutterBadgeManagerApi.remove"],
            "Pigeon remove handler should be installed"
        )
    }

    func testIsSupported() throws {
        let plugin = FlutterBadgeManagerPlugin()
        XCTAssertEqual(try plugin.isSupported(), true)
    }

    func testUpdateValid() throws {
        let plugin = FlutterBadgeManagerPlugin()
        XCTAssertNoThrow(try plugin.update(count: 3))
    }

    func testUpdateInvalid() {
        let plugin = FlutterBadgeManagerPlugin()
        XCTAssertThrowsError(try plugin.update(count: -1)) { error in
            let pigeonError = error as? PigeonError
            XCTAssertEqual(pigeonError?.code, "invalid_args")
        }
    }

    func testRemove() throws {
        let plugin = FlutterBadgeManagerPlugin()
        XCTAssertNoThrow(try plugin.remove())
    }
}
