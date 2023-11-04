import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct EnumComparableMacro {}

extension EnumComparableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(EnumComparableDiagnostic.requiresEnum.diagnose(at: declaration))
            return []
        }

        let enumName = enumDecl.name
        let cases = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self)?.elements }
            .flatMap { $0.map { $0.name }}

        if cases.isEmpty {
            return []
        }

        let _enumName = TokenSyntax.identifier("_\(enumName)")
        let associatedValueErasedEnum = EnumDeclSyntax(
            name: _enumName,
            memberBlockBuilder: {
                MemberBlockItemListSyntax {
                    for caseName in cases {
                        MemberBlockItemSyntax(
                            decl: EnumCaseDeclSyntax {
                                EnumCaseElementListSyntax {
                                    EnumCaseElementSyntax(name: caseName)
                                }
                            }
                        )
                    }
                }
            }
        )

        let returnType = ReturnClauseSyntax(type: TypeSyntax("Bool"))
        let parameterClause = FunctionParameterClauseSyntax(parameters: FunctionParameterListSyntax(itemsBuilder: {
            FunctionParameterListSyntax(arrayLiteral: FunctionParameterSyntax(
                firstName: TokenSyntax(.wildcard, presence: .present),
                secondName: "rhs",
                type: TypeSyntax(stringLiteral: _enumName.text)
            ))
        }))
        let compareFunctionDecl = FunctionDeclSyntax(
            name: "`is`",
            signature: FunctionSignatureSyntax(
                parameterClause: parameterClause,
                returnClause: returnType
            )
        ) {
            SwitchExprSyntax(
                subject: TupleExprSyntax(
                    elements: LabeledExprListSyntax([
                        LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: "self"), trailingComma: .commaToken()),
                        LabeledExprSyntax(expression: DeclReferenceExprSyntax(baseName: "rhs"))
                    ])
                ),
                cases: SwitchCaseListSyntax(cases.map({ caseName in
                        .switchCase(SwitchCaseSyntax(
                            label: .case(SwitchCaseLabelSyntax(caseItems: SwitchCaseItemListSyntax(itemsBuilder: {
                                SwitchCaseItemSyntax(
                                    pattern: ExpressionPatternSyntax(
                                        expression: TupleExprSyntax(
                                            elements: LabeledExprListSyntax(itemsBuilder: {
                                                LabeledExprSyntax(expression: MemberAccessExprSyntax(name: caseName))
                                                LabeledExprSyntax(expression: MemberAccessExprSyntax(name: caseName))
                                            })
                                        )
                                    )
                                )
                            }))),
                            statements: CodeBlockItemListSyntax(itemsBuilder: {
                                ReturnStmtSyntax(expression: BooleanLiteralExprSyntax(true))
                            })
                        ))
                }) + [
                    .switchCase(SwitchCaseSyntax(
                        label: .default(SwitchDefaultLabelSyntax()),
                        statements: CodeBlockItemListSyntax(itemsBuilder: {
                            ReturnStmtSyntax(expression: BooleanLiteralExprSyntax(false))
                        })
                    ))
                ])
            )
        }

        return [
            DeclSyntax(associatedValueErasedEnum),
            DeclSyntax(compareFunctionDecl)
        ]
    }
}

@main
struct EnumComparablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumComparableMacro.self,
    ]
}
