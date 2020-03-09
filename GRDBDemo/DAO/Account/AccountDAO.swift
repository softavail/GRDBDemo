import Foundation
import GRDB

final class AccountDAO: AccountDAOProtocol {
    
    private let dbManager: DBManagerProtocol
    
    init(dbManager: DBManagerProtocol) {
        self.dbManager = dbManager
    }
    
    
    // MARK: - Account
    
    func fetchAccount(byId accountId: String) -> DBAccount? {
        return dbManager.fetch { db in
            return try DBAccount.account(from: db, accountId: accountId)
        }
    }
    
    func fetchAccount(byQRCode qrCode: String) -> DBAccount? {
        return dbManager.fetch { db in
            return try DBAccount.account(from: db, qrCode: qrCode)
        }
    }
    
    func fetchAccount(by rowID: Int64) -> DBAccount? {
        return dbManager.fetch { db in
            return try DBAccount.account(from: db, rowID: rowID)
        }
    }
}
