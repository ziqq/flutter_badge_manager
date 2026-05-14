import XCTest
#if canImport(Flutter)
import Flutter
#elseif canImport(FlutterMacOS)
import FlutterMacOS
#endif
@testable import flutter_badge_manager_foundation

final class FlutterBadgeManagerPluginTests: XCTestCase {
    private final class SpyBadgeWriter: BadgeWriting {
        var values: [Int] = []

        func setBadge(_ value: Int) {
            values.append(value)
        }
    }

    #if os(iOS)
    private final class SpyNotificationCenter: UserNotificationCenterBadgeSetting {
        var values: [Int] = []
        var onSet: (() -> Void)?

        func setBadgeCount(_ value: Int, completionHandler: ((Error?) -> Void)?) {
            values.append(value)
            onSet?()
            completionHandler?(nil)
        }
    }

    private final class SpyNotificationSettingsReader:
        UserNotificationCenterSettingsReading
    {
        var badgeSetting: UNNotificationSetting

        init(badgeSetting: UNNotificationSetting) {
            self.badgeSetting = badgeSetting
        }

        func getNotificationSettings(
            completionHandler: @escaping (UNNotificationSettings) -> Void
        ) {
            completionHandler(StubNotificationSettings(badgeSetting: badgeSetting))
        }
    }

    private final class StubNotificationSettings: UNNotificationSettings {
        private let storedBadgeSetting: UNNotificationSetting

        init(badgeSetting: UNNotificationSetting) {
            self.storedBadgeSetting = badgeSetting
            super.init()
        }

        override var badgeSetting: UNNotificationSetting {
            storedBadgeSetting
        }
    }

    private final class SpyApplicationBadgeSetter: ApplicationBadgeSetting {
        var values: [Int] = []
        var onSet: (() -> Void)?

        func setApplicationIconBadgeNumber(_ value: Int) {
            values.append(value)
            onSet?()
        }
    }
    #endif

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
        let messenger: FlutterBinaryMessenger
        init(messenger: DummyMessenger) { self.messenger = messenger }
        #if canImport(Flutter)
        func messenger() -> FlutterBinaryMessenger { messenger }
        #endif
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
        let writer = SpyBadgeWriter()
        let plugin = FlutterBadgeManagerPlugin(badgeWriter: writer)
        XCTAssertEqual(try plugin.isSupported(), true)
    }

    func testUpdateValid() throws {
        let writer = SpyBadgeWriter()
        let plugin = FlutterBadgeManagerPlugin(badgeWriter: writer)
        XCTAssertNoThrow(try plugin.update(count: 3))
        XCTAssertEqual(writer.values, [3])
    }

    func testUpdateInvalid() {
        let plugin = FlutterBadgeManagerPlugin()
        XCTAssertThrowsError(try plugin.update(count: -1)) { error in
            let pigeonError = error as? PigeonError
            XCTAssertEqual(pigeonError?.code, "invalid_args")
        }
    }

    func testRemove() throws {
        let writer = SpyBadgeWriter()
        let plugin = FlutterBadgeManagerPlugin(badgeWriter: writer)
        XCTAssertNoThrow(try plugin.remove())
        XCTAssertEqual(writer.values, [0])
    }

    #if os(iOS)
    func testIOSBadgeWriterUsesModernBadgeAPIWhenAvailable() {
        let notificationCenter = SpyNotificationCenter()
        let notificationSettingsReader = SpyNotificationSettingsReader(
            badgeSetting: .enabled
        )
        let application = SpyApplicationBadgeSetter()
        let writer = IOSBadgeWriter(
            notificationCenter: notificationCenter,
            notificationSettingsReader: notificationSettingsReader,
            application: application,
            supportsModernBadgeAPI: { true }
        )
        let expectation = expectation(description: "modern badge API")
        notificationCenter.onSet = {
            expectation.fulfill()
        }

        writer.setBadge(7)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(notificationCenter.values, [7])
        XCTAssertEqual(application.values, [7])
    }

    func testIOSBadgeWriterFallsBackToApplicationBadgeOnOlderSystems() {
        let notificationCenter = SpyNotificationCenter()
        let notificationSettingsReader = SpyNotificationSettingsReader(
            badgeSetting: .enabled
        )
        let application = SpyApplicationBadgeSetter()
        let writer = IOSBadgeWriter(
            notificationCenter: notificationCenter,
            notificationSettingsReader: notificationSettingsReader,
            application: application,
            supportsModernBadgeAPI: { false }
        )
        let expectation = expectation(description: "legacy badge API")
        application.onSet = {
            expectation.fulfill()
        }

        writer.setBadge(5)

        waitForExpectations(timeout: 1)
        XCTAssertTrue(notificationCenter.values.isEmpty)
        XCTAssertEqual(application.values, [5])
    }

    func testIOSBadgeWriterSkipsModernBadgeAPIWhenBadgePermissionIsDisabled() {
        let notificationCenter = SpyNotificationCenter()
        let notificationSettingsReader = SpyNotificationSettingsReader(
            badgeSetting: .disabled
        )
        let application = SpyApplicationBadgeSetter()
        let writer = IOSBadgeWriter(
            notificationCenter: notificationCenter,
            notificationSettingsReader: notificationSettingsReader,
            application: application,
            supportsModernBadgeAPI: { true }
        )
        let expectation = expectation(description: "application badge update")
        application.onSet = {
            expectation.fulfill()
        }

        writer.setBadge(7)

        waitForExpectations(timeout: 1)
        XCTAssertTrue(notificationCenter.values.isEmpty)
        XCTAssertEqual(application.values, [7])
    }
    #endif
}
