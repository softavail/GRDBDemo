
import Foundation
import GRDB

final class IdentityDAO: IdentityDAOProtocol {
    
    private let dbManager: DBManagerProtocol
    
    init(dbManager: DBManagerProtocol) {
        self.dbManager = dbManager
    }
    
    
    // MARK: - Identity
    
    func fetchIdentity(by identityId: String) -> DBIdentity? {
        return dbManager.fetch { db in
            return try DBIdentity.identity(from: db, identityId: identityId)
        }
    }
    
    func fetchIdentity(by rowID: Int64) -> DBIdentity? {
        return dbManager.fetch { db in
            return try DBIdentity.identity(from: db, rowID: rowID)
        }
    }
    
    
    // MARK: - Auth Provider
    
    func fetchAuthProvider(by rowID: Int64) -> DBAuthProvider? {
        return dbManager.fetch { db in
            return try DBAuthProvider.authProvider(from: db, rowID: rowID)
        }
    }
    
    func fetchAuthProviders(by identityId: String) -> [DBAuthProvider]? {
        return dbManager.fetch { db in
            return try DBAuthProvider.authProviders(from: db, identityId: identityId)
        }
    }
}
