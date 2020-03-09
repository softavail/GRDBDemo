
import Foundation

enum SQLComparisionOperator: String {
    case equal
    case less
    case greater
    case lessThanOrEqual
    case greaterThanOrEqual
    
    var stringValue: String {
        switch self {
        case .equal:
            return "="
        case .less:
            return "<"
        case .greater:
            return ">"
        case .lessThanOrEqual:
            return "<="
        case .greaterThanOrEqual:
            return ">="
        }
    }
}
