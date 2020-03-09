
import GRDB

final class AuthProviderTable: Table {
    
    class var name: String {
        return "authProvider"
    }
    
    static func create(in db: Database) throws {
        try db.create(self) { t in
            t.primaryKey([Column.identityId.title, Column.type.title, Column.value.title], onConflict: .replace)
            
            t.column(Column.identityId, .text).notNull()
                .references(IdentityTable.name, column: IdentityTable.Column.id.title, onDelete: .cascade)
            
            t.column(Column.type, .integer).notNull()
            t.column(Column.value, .text).notNull()
            t.column(Column.isAvailableForSearch, .boolean).notNull()
        }
    }
    
    enum Column: Int, Describable {
        case identityId
        case type
        case value
        case isAvailableForSearch
    }
}
