
import GRDB

final class DBAuthProvider: Record, DBModel {

    typealias Columns = AuthProviderTable.Column
    
    enum ProviderType: Int {
        case phone = 0
        case email = 1
        case facebook = 2
        case google = 3
    }

    let identityId: String
    
    let type: ProviderType
    
    let value: String
    
    let isAvailableForSearch: Bool
    
    
    init(identityId: String, type: ProviderType, value: String, isAvailableForSearch: Bool) {
        self.identityId = identityId
        self.type = type
        self.value = value
        self.isAvailableForSearch = isAvailableForSearch
        super.init()
    }

    // MARK: - Record
    
    override class var databaseTableName: String {
        return AuthProviderTable.name
    }
    
    required init(row: Row) {
        identityId = row[Columns.identityId.title]
        let rawType: Int = row[Columns.type.title]
        type = ProviderType(rawValue: rawType)!
        value = row[Columns.value.title]
        isAvailableForSearch = row[Columns.isAvailableForSearch.title]
        super.init()
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.identityId.title] = identityId
        container[Columns.type.title] = type.rawValue
        container[Columns.value.title] = value
        container[Columns.isAvailableForSearch.title] = isAvailableForSearch
    }
    
    
    // MARK: - Query
    
    static func authProvider(from db: Database, rowID: Int64) throws -> DBAuthProvider? {
        return try DBAuthProvider.filter(Column.rowID == rowID).fetchOneConstructed(db)
    }
    
    static func authProviders(from db: Database, identityId: String) throws -> [DBAuthProvider]? {
        let identityIdColumn = Column(Columns.identityId.title)
        return try DBAuthProvider.filter(identityIdColumn == identityId).fetchAllConstructed(db)
    }
}
