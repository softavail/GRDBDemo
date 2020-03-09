
import GRDB

extension TransactionObserver {
    
    func databaseWillCommit() throws {}
    func databaseDidCommit(_ db: Database) {}
    func databaseDidRollback(_ db: Database) {}
}
