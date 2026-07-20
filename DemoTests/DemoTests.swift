import XCTest
@testable import Demo

final class DemoTests: XCTestCase {
    func testStarterConfigurationUsesExpectedIdentity() {
        XCTAssertEqual(AppConfiguration.displayName, "Demo")
        XCTAssertEqual(AppConfiguration.monthlyProductID, "com.hoangbkit.Demo.pro.monthly")
        XCTAssertEqual(AppConfiguration.yearlyProductID, "com.hoangbkit.Demo.pro.yearly")
    }

    func testStarterURLsAreHTTPS() {
        XCTAssertEqual(AppConfiguration.supportURL.scheme, "https")
        XCTAssertEqual(AppConfiguration.privacyURL.scheme, "https")
        XCTAssertEqual(AppConfiguration.termsURL.scheme, "https")
    }
}
