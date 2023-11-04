import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

enum EnumComparableDiagnostic {
    case requiresEnum
}

extension EnumComparableDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol, fixIts: [FixIt] = []) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self, fixIts: fixIts)
    }

    var message: String {
        switch self {
        case .requiresEnum:
            return "EnumComparable macro can only be applied to an enum."
        }
    }
    
    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "swift", id: String(describing: self))
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity { .error }
}
