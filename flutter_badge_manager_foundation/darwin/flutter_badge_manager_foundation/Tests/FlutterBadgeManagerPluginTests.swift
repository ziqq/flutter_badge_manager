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
        XCTAssertNotNil(messenger.handlers["flutter_badge_manager_foundation"], "Channel handler should be installed")
    }

    func testHandleIsSupported() {
        let plugin = FlutterBadgeManagerPlugin()
        let expectation = self.expectation(description: "isSupported")
        plugin.handle(FlutterMethodCall(methodName: "isSupported", arguments: nil)) { value in
            XCTAssertTrue(value as? Bool ?? false)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testHandleUpdateValid() {
        let plugin = FlutterBadgeManagerPlugin()
        let expectation = self.expectation(description: "update")
        plugin.handle(FlutterMethodCall(methodName: "update", arguments: ["count": 3])) { value in
            XCTAssertNil(value)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testHandleUpdateInvalid() {
        let plugin = FlutterBadgeManagerPlugin()
        let expectation = self.expectation(description: "update_invalid")
        plugin.handle(FlutterMethodCall(methodName: "update", arguments: ["count": -1])) { value in
            let error = value as? FlutterError
            XCTAssertEqual(error?.code, "invalid_args")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testHandleRemove() {
        let plugin = FlutterBadgeManagerPlugin()
        let expectation = self.expectation(description: "remove")
        plugin.handle(FlutterMethodCall(methodName: "remove", arguments: nil)) { value in
            XCTAssertNil(value)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testUnsupportedMethod() {
        let plugin = FlutterBadgeManagerPlugin()
        let expectation = self.expectation(description: "unsupported")
        plugin.handle(FlutterMethodCall(methodName: "unknown", arguments: nil)) { value in
            let error = value as? FlutterMethodNotImplemented
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
