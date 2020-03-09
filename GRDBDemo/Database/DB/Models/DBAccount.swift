
import GRDB


/// Database representation of `NYNAccountDetails`.
final class DBAccount: Record, DBModel {
    
    enum Role: String {
        case user
        case admin
    }

    let accountId: String
    let identityId: String
    let authenticationIdentifier: String
    let authenticationType: String
    let avatar: String?
    let accountMark: String?
    let accountName: String?
    let firstName: String
    let lastName: String?
    let username: String
    let status: Int
    let qrCode: String?
    let birthday: Int64?
    let roles: [Role]?
    let created: Int64?
    let updated: Int64?
    
    
    // MARK: - Init
    
    init(accountId: String,
         identityId: String,
         authenticationIdentifier: String,
         authenticationType: String,
         avatar: String?,
         accountMark: String?,
         accountName: String?,
         firstName: String,
         lastName: String?,
         username: String,
         status: Int,
         qrCode: String?,
         birthday: Int64?,
         roles: [Role]?,
         created: Int64?,
         updated: Int64?)
    {
        self.accountId = accountId
        self.identityId = identityId
        self.authenticationIdentifier = authenticationIdentifier
        self.authenticationType = authenticationType
        self.avatar = avatar
        self.accountMark = accountMark
        self.accountName = accountName
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.status = 1
        self.qrCode = qrCode
        self.birthday = birthday
        self.roles = roles
        self.created = created
        self.updated = updated
        super.init()
    }

    // MARK: - Record
    
    override class var databaseTableName: String {
        return AccountTable.name
    }
    
    required init(row: Row) {
        accountId = row[AccountTable.Column.accountId.title]
        identityId = row[AccountTable.Column.identityId.title]
        authenticationIdentifier = row[AccountTable.Column.authenticationIdentifier.title]
        authenticationType = row[AccountTable.Column.authenticationType.title]
        avatar = row[AccountTable.Column.avatar.title]
        accountMark = row[AccountTable.Column.accountMark.title]
        accountName = row[AccountTable.Column.accountName.title]
        firstName = row[AccountTable.Column.firstName.title]
        lastName = row[AccountTable.Column.lastName.title]
        username = row[AccountTable.Column.username.title]
        status = row[AccountTable.Column.status.title]
        qrCode = row[AccountTable.Column.qrCode.title]
        birthday = row[AccountTable.Column.birthday.title]
        let rawRoles: String? = row[AccountTable.Column.birthday.title]
        roles = rawRoles?
            .components(separatedBy: ",")
            .compactMap { Role(rawValue: $0) }
        created = row[AccountTable.Column.created.title]
        updated = row[AccountTable.Column.updated.title]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[AccountTable.Column.accountId.title] = accountId
        container[AccountTable.Column.identityId.title] = identityId
        container[AccountTable.Column.authenticationIdentifier.title] = authenticationIdentifier
        container[AccountTable.Column.authenticationType.title] = authenticationType
        container[AccountTable.Column.avatar.title] = avatar
        container[AccountTable.Column.accountMark.title] = accountMark
        container[AccountTable.Column.accountName.title] = accountName
        container[AccountTable.Column.firstName.title] = firstName
        container[AccountTable.Column.lastName.title] = lastName
        container[AccountTable.Column.username.title] = username
        container[AccountTable.Column.status.title] = status
        container[AccountTable.Column.qrCode.title] = qrCode
        container[AccountTable.Column.birthday.title] = birthday
        container[AccountTable.Column.roles.title] = roles?.map { $0.rawValue }.joined(separator: ",")
        container[AccountTable.Column.created.title] = created
        container[AccountTable.Column.updated.title] = updated
    }
    
    
    // MARK: - DBModel
    
    func saveAggregate(_ db: Database) throws {
        try save(db)
    }
    
    func construct(_ db: Database) throws {
    }
    
    
    // MARK: - Query
    
    static func account(from db: Database, rowID: Int64) throws -> DBAccount? {
        return try DBAccount.filter(Column.rowID == rowID).fetchOneConstructed(db)
    }
    
    static func account(from db: Database, accountId: String) throws -> DBAccount? {
        let accountIdColumn = Column(AccountTable.Column.accountId.title)
        return try DBAccount.filter(accountIdColumn == accountId).fetchOneConstructed(db)
    }
    
    static func account(from db: Database, qrCode: String) throws -> DBAccount? {
        let qrCodeColumn = Column(AccountTable.Column.qrCode.title)
        return try DBAccount.filter(qrCodeColumn == qrCode).fetchOneConstructed(db)
    }
    
    static func accounts(from db: Database, identityId: String) throws -> [DBAccount] {
        let identityIdColumn = Column(AccountTable.Column.identityId.title)
        return try DBAccount.filter(identityIdColumn == identityId).fetchAllConstructed(db)
    }
}
