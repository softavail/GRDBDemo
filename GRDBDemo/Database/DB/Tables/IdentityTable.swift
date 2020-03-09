import GRDB

final class IdentityTable: Table {
    
    class var name: String {
        return "identity"
    }
    
    static func create(in db: Database) throws {
        try db.create(self) { t in
            t.column(Column.id, .text).notNull().primaryKey()
            t.column(Column.passcode, .text)
            t.column(Column.defaultAccountId, .text)
        }
    }
    
    enum Column: Int, Describable {
        case id
        case passcode
        case defaultAccountId
    }
}
