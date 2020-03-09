
import Foundation

typealias KeychainQuery = [String: AnyHashable]

private extension KeychainService {
    enum Consts {
        enum Values {
            static let account = "UserAccount"
        }
    }
}

extension KeychainService {
    enum Keys {
        static let dataBasePassphrase = "com.nynja.mobile.communicator.storage.service.passphrase"
    }
}

final class KeychainService {

    private let queryFactory = QueryFactory()
    
    // MARK: Init
    
    static let standard = KeychainService()

    private init() {}

    
    // MARK: String
    
    func string(forKey key: String, secure: Bool = true) -> String? {
        let query = queryFactory.makeQuery(
            for: QueryInfo(
                key: key,
                account: Consts.Values.account,
                kind: .get,
                isSecure: secure))
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        guard let data = queryResult as? Data, status == errSecSuccess else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    func set(_ string: String, forKey key: String, secure: Bool = true) -> Bool {
        guard let stringData = string.data(using: .utf8) else {
            return false
        }

        delete(key: key, secure: secure)
        
        let query = queryFactory.makeQuery(
            for: QueryInfo(
                key: key,
                account: Consts.Values.account,
                kind: .set(stringData),
                isSecure: secure))
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }

    @discardableResult
    func delete(key: String, secure: Bool = true) -> Bool {
        let query = queryFactory.makeQuery(
            for: QueryInfo(
                key: key,
                account: Consts.Values.account,
                kind: .delete,
                isSecure: secure))
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    
    // MARK: - Clear
    
    @discardableResult
    func clear() -> Bool {
        let queries = queryFactory.makeAllClassesQuery()

        return queries.reduce(true) { partial, query in
            let deleteResult = SecItemDelete(query as CFDictionary)
            let isSuccess = deleteResult == errSecSuccess || deleteResult == errSecItemNotFound
            return partial && isSuccess
        }
    }

}
