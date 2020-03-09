
import GRDB

final class AccountTable: Table {
    
    class var name: String {
        return "account"
    }
    
    static func create(in db: Database) throws {
        try db.create(self) { t in
            t.column(Column.accountId, .text).notNull().primaryKey()
            
            t.column(Column.identityId, .text).notNull()
                .references(IdentityTable.name, column: IdentityTable.Column.id.title, onDelete: .cascade)
            
            t.column(Column.authenticationIdentifier, .text)
            t.column(Column.authenticationType, .text)
            t.column(Column.avatar, .text)
            t.column(Column.accountMark, .text)
            t.column(Column.accountName, .text)
            t.column(Column.firstName, .text)
            t.column(Column.lastName, .text)
            t.column(Column.username, .text)
            t.column(Column.status, .text)
            t.column(Column.qrCode, .text)
            t.column(Column.birthday, .integer)
            t.column(Column.roles, .text)
            t.column(Column.created, .integer)
            t.column(Column.updated, .integer)
        }
    }
    
    enum Column: Int, Describable {
        case accountId
        case identityId
        case authenticationIdentifier
        case authenticationType
        case avatar
        case accountMark
        case accountName
        case firstName
        case lastName
        case username
        case status
        case qrCode
        case birthday
        case roles
        case created
        case updated
    }
}
