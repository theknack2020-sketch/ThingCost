import Foundation
import Testing
@testable import ThingCost

/// Covers locale-aware price parsing (ship-review r2 major: comma-decimal
/// regions could not enter fractional prices because Double(_:) is C-locale only).
@Suite("Localized decimal parsing")
struct DecimalParsingTests {
    @Test("Period decimal parses")
    func periodParses() {
        #expect("12.99".localizedDecimalValue == 12.99)
    }

    @Test("Whole number parses")
    func wholeParses() {
        #expect("1000".localizedDecimalValue == 1000)
    }

    @Test("Comma decimal is accepted via fallback normalization")
    func commaParses() {
        // Regardless of the test host's locale, a stray comma must not yield nil.
        #expect("12,99".localizedDecimalValue == 12.99)
    }

    @Test("Empty string is nil")
    func emptyIsNil() {
        #expect("".localizedDecimalValue == nil)
    }

    @Test("Non-numeric is nil")
    func garbageIsNil() {
        #expect("abc".localizedDecimalValue == nil)
    }
}
