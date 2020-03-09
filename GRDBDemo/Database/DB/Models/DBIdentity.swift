
import GRDB

final class DBIdentity: Record, DBModel {

    typealias Columns = IdentityTable.Column
    
    let id: String
    
    let passcode: String?
    
    let defaultAccountId: String
    
    private(set) var authProviders: [DBAuthProvider]
    
    
    
    // MARK: - Init
    init(id: String, passcode: String, defaultAccountId: String, authProviders: [DBAuthProvider]) {
        self.id = id
        self.passcode = passcode
        self.defaultAccountId = defaultAccountId
        self.authProviders = authProviders
        super.init()
    }

    
    // MARK: - Record
    
    override class var databaseTableName: String {
        return IdentityTable.name
    }
    
    required init(row: Row) {
        id = row[Columns.id.title]
        passcode = row[Columns.passcode.title]
        defaultAccountId = row[Columns.defaultAccountId.title]
        authProviders = []
        super.init()
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.id.title] = id
        container[Columns.passcode.title] = passcode
        container[Columns.defaultAccountId.title] = defaultAccountId
    }
    
    
    // MARK: - DBModel
    
    func saveAggregate(_ db: Database) throws {
        try save(db)
        try authProviders.forEach { try $0.saveAggregate(db) }
    }
    
    func construct(_ db: Database) throws {
        let identityIdColumn = Column(AuthProviderTable.Column.identityId.title)
        
        authProviders = try DBAuthProvider
            .filter(identityIdColumn == id)
            .fetchAll(db)
    }
    
    
    // MARK: - Query
    
    static func identity(from db: Database, rowID: Int64) throws -> DBIdentity? {
        return try DBIdentity.filter(Column.rowID == rowID).fetchOneConstructed(db)
    }
    
    static func identity(from db: Database, identityId: String) throws -> DBIdentity? {
        let identityIdColumn = Column(Columns.id.title)
        return try DBIdentity.filter(identityIdColumn == identityId).fetchOneConstructed(db)
    }
}
