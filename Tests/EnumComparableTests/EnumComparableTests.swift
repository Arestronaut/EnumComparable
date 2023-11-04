import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(EnumComparableMacros)
import EnumComparableMacros

let testMacros: [String: Macro.Type] = [
    "EnumComparable": EnumComparableMacro.self
]
#endif

final class EnumComparableTests: XCTestCase {
    // MARK: Applicability
    func testEnumComparableMacroRequiresEnumOnStruct() throws {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            struct MyStruct {}
            """,
            expandedSource: """
            struct MyStruct {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "EnumComparable macro can only be applied to an enum.",
                    line: 1,
                    column: 1,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }

    func testEnumComparableMacroRequiresEnumOnClass() throws {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            class MyClass {}
            """,
            expandedSource: """
            class MyClass {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "EnumComparable macro can only be applied to an enum.",
                    line: 1,
                    column: 1,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }

    func testEnumComparableMacroRequiresEnumOnActor() throws {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            actor MyActor {}
            """,
            expandedSource: """
            actor MyActor {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "EnumComparable macro can only be applied to an enum.",
                    line: 1,
                    column: 1,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }

    // MARK: Happy Path

    func testEnumComparableMacroNoCaseEnum() {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            enum MyEnum {}
            """,
            expandedSource: """
            enum MyEnum {}
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }

    func testEnumComparableMacroSingleCaseEnum() {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            enum MyEnum {
                case myFirstCase
            }
            """,
            expandedSource: """
            enum MyEnum {
                case myFirstCase

                enum _MyEnum  {
                    case myFirstCase
                }

                func `is`(_ rhs: _MyEnum ) -> Bool {
                    switch (self, rhs) {
                    case (.myFirstCase, .myFirstCase):
                        return true
                    default:
                        return false
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }

    func testEnumComparableMacroSingleCaseEnumWithAssociatedValue() {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            enum MyEnum {
                case myFirstCase(String)
            }
            """,
            expandedSource: """
            enum MyEnum {
                case myFirstCase(String)

                enum _MyEnum  {
                    case myFirstCase
                }

                func `is`(_ rhs: _MyEnum ) -> Bool {
                    switch (self, rhs) {
                    case (.myFirstCase, .myFirstCase):
                        return true
                    default:
                        return false
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }

    func testEnumComparableMacroMixedMultipleCaseEnum() {
        #if canImport(EnumComparableMacros)
        assertMacroExpansion(
            """
            @EnumComparable
            enum MyEnum {
                case myFirstCase(String)
                case mySecondCase
            }
            """,
            expandedSource: """
            enum MyEnum {
                case myFirstCase(String)
                case mySecondCase

                enum _MyEnum  {
                    case myFirstCase
                    case mySecondCase
                }

                func `is`(_ rhs: _MyEnum ) -> Bool {
                    switch (self, rhs) {
                    case (.myFirstCase, .myFirstCase):
                        return true
                    case (.mySecondCase, .mySecondCase):
                        return true
                    default:
                        return false
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Marcos are only supported when running tests for the host platform")
        #endif
    }
}
