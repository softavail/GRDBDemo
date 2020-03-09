
import Foundation

struct QueryInfo {

    enum QueryKind {
        case set(Data)
        case get
        case delete

        var query: KeychainQuery {
            switch self {
            case let .set(data):
                return [QueryFactory.KeychainKeys.Data.value: data]
            case .get:
                return [QueryFactory.KeychainKeys.Data.return: true]
            case .delete:
                return [:]
            }
        }
    }
    
    let key: String
    let account: String
    let kind: QueryKind
    let isSecure: Bool
}

final class QueryFactory: QueryFactoryProtocol {
    
    private let genericPassword = KeychainKeyValues.Class.genericPassword
    private let certificate = KeychainKeyValues.Class.certificate
    
    func makeQuery(for info: QueryInfo) -> KeychainQuery {
        let queryMaker = info.isSecure ? makeSecureQuery : makePlainQuery
        let query = queryMaker(info.key, info.account)
        return query.mergingUniquingFirst(with: info.kind.query)
    }
    
    func makeAllClassesQuery() -> [KeychainQuery] {
        let classKey = KeychainKeys.class
        return [
            [classKey: genericPassword],
            [classKey: certificate],
        ]
    }
}

// MARK: Private
private extension QueryFactory {
    func makeSecureQuery(for label: String, account: String) -> KeychainQuery {
        return [
            KeychainKeys.class: genericPassword,
            KeychainKeys.Attributes.label: label,
            KeychainKeys.Attributes.accessible: KeychainKeyValues.Accessible.afterFirstUnlockThisDeviceOnly,
            KeychainKeys.Attributes.account: account,
        ]
    }

    func makePlainQuery(for label: String, account: String) -> KeychainQuery {
        return [
            KeychainKeys.class: certificate,
            KeychainKeys.Attributes.label: label,
            KeychainKeys.Attributes.accessible: KeychainKeyValues.Accessible.afterFirstUnlockThisDeviceOnly,
        ]
    }
}

private extension QueryFactory {

    enum KeychainKeys {

        static let `class` = kSecClass as String

        enum Data {
            static let value = kSecValueData as String
            static let `return` = kSecReturnData as String
        }

        enum Attributes {
            static let label = kSecAttrLabel as String
            static let account = kSecAttrAccount as String
            static let accessible = kSecAttrAccessible as String
        }
    }

    enum KeychainKeyValues {

        enum Class {
            static let genericPassword = kSecClassGenericPassword as String
            static let certificate = kSecClassCertificate
        }
        
        enum Accessible {
            static let afterFirstUnlockThisDeviceOnly = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
        }
    }
}
