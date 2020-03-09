
import GRDB

final class DBObserver: StorageObserver, TransactionObserver {
    
    // TODO: Notify only if subscribers exists!
    
    static let `default` = DBObserver()
    
    private init() {}
    
    private let processingQueue = DispatchQueue(
        label: String.label(withSuffix: "db-observer.processing-queue"),
        qos: .utility)
    
    
    // MARK: - Dependencies
    
    private let accountDAO: AccountDAOProtocol = AccountDAO(dbManager: StorageService.sharedInstance)
    
    private let identityDAO: IdentityDAOProtocol = IdentityDAO(dbManager: StorageService.sharedInstance)
    
    
    // MARK: - Properties
    
    var subscribers: [SubscribeType: [StorageSubscriberReference]] = [:]
    
    let isolationQueue = DispatchQueue(label: String.label(withSuffix: "db-observer.isolation-queue"))
    
    // swiftformat:disable:next typeSugar
    private var allChanges: Dictionary<String, [ChangeInfo]> = [:]
    
    private let tableNames: [String] = {
        let tables: [Table.Type] = [
            IdentityTable.self,
            AccountTable.self,
            AuthProviderTable.self,
        ]
        return tables.map { $0.name }
    }()
    
    
    // MARK: - TransactionObserver
    
    func observes(eventsOfKind eventKind: DatabaseEventKind) -> Bool {
        switch eventKind.tableName {
        default:
            return tableNames.contains(eventKind.tableName)
        }
    }
    
    func databaseDidChange(with event: DatabaseEvent) {
        processingQueue.async { [unowned self] in
            self.handleDidChange(with: event)
        }
    }
    
    private func handleDidChange(with event: DatabaseEvent) {
        var temp = allChanges[event.tableName] ?? []
        temp.append(ChangeInfo(event: event))
        allChanges[event.tableName] = temp
    }
    
    func databaseWillCommit() throws {
        processingQueue.async { [unowned self] in
            self.handleWillCommit()
        }
    }
    
    private func handleWillCommit() {
        allChanges.forEach { tableName, changes in
            changes.forEach { info in
                guard info.kind != .insert else { return }
                info.oldValue = fetchValue(for: tableName, event: info.event)
            }
        }
    }
    
    func databaseDidCommit(_ db: Database) {
        processingQueue.async { [unowned self] in
            self.handleDidCommit(db)
        }
    }
    
    private func handleDidCommit(_ db: Database) {
        allChanges.forEach { tableName, changes in
            switch tableName {
            case IdentityTable.name:
                handleIdentityDidCommit(changes: changes)
            case AccountTable.name:
                handleAccountDidCommit(changes: changes)
            case AuthProviderTable.name:
                handleAuthProviderDidCommit(changes: changes)
            default:
                break
            }
        }
        
        clear()
    }
    
    private func handleIdentityDidCommit(changes: [ChangeInfo]) {
        let storageChanges: [StorageChange] = changes.map { storageChange(from: $0) }
        notify(with: storageChanges, type: .identity)
    }
    
    private func handleAccountDidCommit(changes: [ChangeInfo]) {
        var storageChanges: [StorageChange] = []
        
        changes.forEach { info in
            let change = storageChange(from: info)
            storageChanges.append(change)
            
            let account = changedValue(from: info) as? DBAccount
            notify(with: info.event, entity: [change], type: .account(account?.accountId))
        }
        
        notify(with: storageChanges, type: .account(nil))
    }

    private func handleAuthProviderDidCommit(changes: [ChangeInfo]) {
        let storageChanges: [StorageChange] = changes.map { storageChange(from: $0) }
        notify(with: storageChanges, type: .authProvider)
    }
    
    func databaseDidRollback(_ db: Database) {
        processingQueue.async {
            self.clear()
        }
    }
    
    // MARK: - Private
    private func clear() {
        allChanges = [:]
    }
    
    private func fetchValue(for tableName: String, event: DatabaseEvent) -> Any? {
        let value: Any?
        
        switch tableName {
        case IdentityTable.name:
            value = identityDAO.fetchIdentity(by: event.rowID)
        case AccountTable.name:
            value = accountDAO.fetchAccount(by: event.rowID)
        case AuthProviderTable.name:
            value = identityDAO.fetchAuthProvider(by: event.rowID)
        default:
            value = nil
        }
        
        return value
    }
    
    private func changedValue(from info: ChangeInfo) -> Any? {
        let entity: Any?
        
        if info.kind != .delete {
            info.newValue = fetchValue(for: info.event.tableName, event: info.event)
            entity = info.newValue
        } else {
            entity = info.oldValue
        }
        
        return entity
    }
    
    private func storageChange(from info: ChangeInfo) -> StorageChange {
        let value = changedValue(from: info)
        let kind = StorageChangeKind(kind: info.kind)
        return StorageChange(kind: kind, entity: value)
    }
    
    private func notify(with event: DatabaseEvent, entity: Any, type: SubscribeType) {
        let kind = StorageChangeKind(kind: event.kind)
        let change = StorageChange(kind: kind, entity: entity)
        notify(with: [change], type: type)
    }
}

// MARK: - Change
extension StorageChangeKind {
    
    init(kind: DatabaseEvent.Kind) {
        switch kind {
        case .insert:
            self = .insert
        case .update:
            self = .update
        case .delete:
            self = .delete
        }
    }
}

extension DBObserver {
    
    private class ChangeInfo {
        let event: DatabaseEvent
        var oldValue: Any?
        var newValue: Any?
        
        var kind: DatabaseEvent.Kind {
            return event.kind
        }
        
        var rowID: Int64 {
            return event.rowID
        }
        
        init(event: DatabaseEvent) {
            self.event = event
        }
    }
}
