import GRDB

final class DatabaseManager: DBManagerProtocol {
    enum DatabaseManagerError: Error {
        case noPassphrase
    }

    
    private typealias ReadClosure = (Database) throws -> Void
    private typealias WriteInTransactionClosure = (Database) throws -> Database.TransactionCompletion
    
    private enum DatabaseError: Error {
        case hasNoDBFile
    }
    
    private(set) var dbPool: DatabasePool?
    
    private static let sqlCipherVersionKey = "sqlCipherVersion"
    private static let currentSqlCipherVersion = "4"
    
    //
    private static let kSqliteHeaderLength: UInt = 32
    private static let kSQLCipherSaltLength: UInt = 16
    private static let kSQLCipherDerivedKeyLength: UInt = 32
    private static let kSQLCipherKeySpecLength: UInt = 48
    private static let kSQLCipherSaltKey = "kSQLCipherSaltKey"

    private var currentPassphrase: String?
    
    private static let kConvertToPlainHeader = false

    private var savedSalt: String?
    
    // MARK: - Perform changes in DB
    
    private func inDatabase(_ block: (DatabasePool) throws -> Void) throws {
        do {
            if let dbPool = self.dbPool {
                try block(dbPool)
            }
        } catch {
            //LogService.log(topic: .db) { return error.localizedDescription }
            throw error
        }
    }
    
    private func read(_ block: ReadClosure) throws {
        try inDatabase { dbPool in
            try dbPool.read { db in
                try block(db)
            }
        }
    }
    
    private func writeInTransaction(_ block: WriteInTransactionClosure) throws {
        try inDatabase { dbPool in
            try dbPool.writeInTransaction { db in
                return try block(db)
            }
        }
    }

    // MARK: - Setup DB
    
    func setupDatabase(with name: String, encryptionMode mode: EncryptionMode, application: UIApplication) -> Bool {
        var fOk = true
        
        do {
            let name = "\(name).sqlite"
            let appSupportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] as String
            let path = appSupportDirectory + "/\(name)"
            
            try? FileManager.default.removeItem(atPath: path)
            
            if !FileManager.default.fileExists(atPath: appSupportDirectory, isDirectory: nil) {
                let url = URL(fileURLWithPath:  appSupportDirectory)
                try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: path) {
                migrateToSQLCipher4IfNecessary(at: path, key: mode.oldPassphrase)
                try setupExistedDatabase(at: path, mode: mode)
            } else {
                try setupNewDatabase(at: path, mode: mode)
            }
            UserDefaults.standard.set(DatabaseManager.currentSqlCipherVersion, forKey: DatabaseManager.sqlCipherVersionKey)
            UserDefaults.standard.synchronize()

            dbPool?.add(transactionObserver: DBObserver.default)
            dbPool?.setupMemoryManagement(in: application)
            print("success")
        } catch {
            print("error: \(error.localizedDescription)")
            fOk = false
        }
        return fOk
    }

    private func setupExistedDatabase(at path: String, mode: EncryptionMode) throws {
        //LogService.log(topic: .db) { return "db path: \(path)" }

        var configuration = Configuration()
        self.currentPassphrase = mode.oldPassphrase
        
        configuration.prepareDatabase = { db in
            if let passphrase = self.currentPassphrase {
                try db.usePassphrase(passphrase)
            }
            
            if DatabaseManager.kConvertToPlainHeader {
                do {
                    try db.execute(sql: "PRAGMA cipher_plaintext_header_size = \(DatabaseManager.kSqliteHeaderLength)")
                } catch {}

                if let salt = self.savedSaltIfAny() {
                    try db.execute(sql: "PRAGMA cipher_salt = \"x'\(salt)'\"")
                }
            }
        }

        dbPool = try DatabasePool(path: path, configuration: configuration)
        //LogService.log(topic: .db) { return "try performMigration" }
        try performMigration()
        
        if let newPassphrase = mode.newPassphrase {
            //LogService.log(topic: .db) { return " change phrase" }
            try dbPool?.barrierWriteWithoutTransaction { db in
                //LogService.log(topic: .db) { return " change phrase begin" }
                try db.changePassphrase(newPassphrase)
                //LogService.log(topic: .db) { return " change phrase end" }
                dbPool?.invalidateReadOnlyConnections()
                self.currentPassphrase = newPassphrase
            }
        }
        //LogService.log(topic: .db) { return "end" }
    }

    private func openDatabase(at path: String, mode: EncryptionMode) throws {
        var configuration = Configuration()
        
        self.currentPassphrase = mode.oldPassphrase

        configuration.prepareDatabase = { db in
            if let passphrase = self.currentPassphrase {
                try db.usePassphrase(passphrase)
            }

            if DatabaseManager.kConvertToPlainHeader {
                
                try db.execute(sql: "PRAGMA cipher_plaintext_header_size = \(DatabaseManager.kSqliteHeaderLength)")
            
                if let salt = self.savedSaltIfAny() {
                    try db.execute(sql: "PRAGMA cipher_salt = \"x'\(salt)'\"")
                }
            }
        }
        
        dbPool = try DatabasePool(path: path, configuration: configuration)
    }

    private func setupNewDatabase(at path: String, mode: EncryptionMode) throws {
        print("db path: \(path)")

        guard FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) else {
            print("could not create file at db path: \(path)")
            return
        }
        
        var configuration = Configuration()
        self.currentPassphrase = mode.newPassphrase
        
        configuration.prepareDatabase = { db in
            if let passphrase = self.currentPassphrase {
                try db.usePassphrase(passphrase)
            }
        }

        dbPool = try DatabasePool(path: path, configuration: configuration)
        createTables()
    }
    
    private func createTables() {
        try? write { db in
            try DatabaseManager.tables.forEach {
                try $0.create(in: db)
            }
            
        }
    }
    
    private func performMigration() throws {
    }

    private func shouldMigrateToSQLCipher4() -> Bool {
        let defaults = UserDefaults.standard
        
        guard (defaults.object(forKey: DatabaseManager.sqlCipherVersionKey) as? String) != nil else {
            return true
        }
        
        // For now we dont have to check sqlCipherVErsion because this is the first time migration is needed
        return false
    }

    private func migrateToSQLCipher4IfNecessary(at path: String, key passphrase: String?) {
        let defaults = UserDefaults.standard
        
        guard (defaults.object(forKey: DatabaseManager.sqlCipherVersionKey) as? String) != nil else {
            try? migrateToSQLCipher4(at: path, key: passphrase)
            return
        }
        
        // For now we dont have to check sqlCipherVErsion because this is the first time migration is needed
    }
    
    private func migrateToSQLCipher4(at path: String, key passphrase: String?) throws {
        var config = Configuration()
        
        config.prepareDatabase = { db in

            if let passphrase = passphrase {
                try db.usePassphrase(passphrase)
            }

            try db.execute(sql: "PRAGMA cipher_migrate")
            //LogService.log(topic: .db) { return "[SQLCipher4] PRAGMA cipher_migrate OK" }
        }
        
        _ = try DatabaseQueue(path: path, configuration: config)
        //LogService.log(topic: .db) { return "[SQLCipher4] migrateToSQLCipher4 OK" }
    }

    private func doesDatabaseNeedToBeConverted(at path: String) -> Bool {
        let kUnencryptedHeader = "SQLite format 3\0"

        guard !path.isEmpty else { return false }
        guard let headerData = readFirstNBytesOfDatabaseFile(at: path, bytes: DatabaseManager.kSqliteHeaderLength) else { return false }
        guard let unencryptedHeaderData = kUnencryptedHeader.data(using: .utf8) else { return false }
        let isUnencrypted = unencryptedHeaderData.elementsEqual(headerData.subdata(in: 0..<unencryptedHeaderData.count))
        
        return !isUnencrypted
    }

    private func readFirstNBytesOfDatabaseFile(at path: String, bytes count: UInt) -> Data? {
        
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else { return nil }
        
        let headerData = data.subdata(in: 0..<Data.Index(count))
        return headerData
    }
    

    private func savedSaltIfAny() -> String? {
        return self.savedSalt /* KeychainService.standard.string(forKey: DatabaseManager.kSQLCipherSaltKey) */
    }

    // MARK: - Drop DB
    
    func clear() {
        dbPool = nil
        //LogService.log(topic: .db) { return "Clear database" }
    }
    
    // MARK: - Fetching
    
    func fetch<T>(_ closure: (Database) throws -> T?) -> T? {
        var model: T?
        
        try? read { db in
            model = try closure(db)
        }
        
        return model
    }
    
    func fetch<T>(_ closure: (Database) throws -> [T]) -> [T] {
        var models: [T] = []
        
        try? read { db in
            models = try closure(db)
        }
        
        return models
    }

    func fetchCount(_ closure: (Database) throws -> Int) -> Int {
        var count: Int = 0
        
        try? read { db in
            count = try closure(db)
        }
        
        return count
    }

    func rowExists<T: Table>(in table: T.Type, where condition: String, arguments: StatementArguments?) -> Bool {
        let sql = """
        SELECT EXISTS(SELECT 1 FROM \(T.name) WHERE \(condition))
        """

        return fetch { db in
            return try SQLRequest(sql: sql, arguments: arguments ?? StatementArguments()).fetchOne(db)
        } ?? false
    }
    
    // MARK: - Writing
    func write(_ closure: (Database) throws -> Void) throws {
        try inDatabase { dbPool in
            try dbPool.write { db in
                try closure(db)
            }
        }
    }
    
    // MARK: - Perform Actions with DB
    
    func perform(action: DatabaseAction, with model: DBModelConvertible) throws {
        guard let dbModel = model.databaseModel else { return }
        try perform(action: action, with: dbModel)
    }
    
    func perform(action: DatabaseAction, with model: DBModel) throws {
        try perform(action: action, with: [model])
    }
    
    func perform(action: DatabaseAction, with models: [DBModelConvertible]) throws {
        let models = models.compactMap { $0.databaseModel }
        try perform(action: action, with: models)
    }
    
    func perform(action: DatabaseAction, with models: [DBModel]) throws {
        try write { db in
            try models.forEach { model in
                switch action {
                case .save:
                    try model.saveAggregate(db)
                case .delete:
                    try model.deleteAggregate(db)
                case .update:
                    try model.update(db)
                case let .updateColumns(columns):
                    try model.update(db, columns: columns)
                }
            }
        }
    }
}


// MARK: - Tables

extension DatabaseManager {
    
    /// NOTE: The order of tables in the array is NECESSARY because of Foreign Key references.
    /// For 'clearDatabase()' method we should use the same array but in reversed order.
    static let tables: [Table.Type] = [
        
        IdentityTable.self,
        AuthProviderTable.self,
        
        AccountTable.self,
    ]
}


// MARK: - EncryptionMode

extension DatabaseManager {
    
    enum EncryptionMode {
        case reencrypt(usingOld: String?, new: String?)
        case none

        var shouldEncrypt: Bool {
            if case .none = self {
                return false
            }
            
            return true
        }
        
        var newPassphrase: String? {
            if case .reencrypt(usingOld: _, new: let new) = self {
                return new
            }
            
            return nil
        }
        
        var oldPassphrase: String? {
            if case .reencrypt(usingOld: let old, new: _) = self {
                return old
            }
            
            return nil
        }
        
        func passphraseForFirstEncryption(_ isFirstEncryption: Bool) -> String? {
            return isFirstEncryption ? newPassphrase : oldPassphrase
        }
    }
}
