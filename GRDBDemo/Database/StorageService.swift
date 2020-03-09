import CryptoSwift
import Foundation
import GRDB

/// Thread-safe
final class StorageService {
    
    private let passphraseKey = KeychainService.Keys.dataBasePassphrase
    
    let keychain = KeychainService.standard 
    
    private let databaseManager = DatabaseManager()
    
    var dbPool: DatabasePool? {
        return databaseManager.dbPool
    }
    
    private let isolationQueue = DispatchQueue(label: String.label(withSuffix: "storage-service.isolation-queue"))
    
    // MARK: - Singleton
    
    static let sharedInstance = StorageService()
    
    private init() {
    }
    
    
    // MARK: - Setup
    
    func setupDatabase(with name: String, application: UIApplication) {
        isolationQueue.sync { [weak self] in
            self?._setupDatabase(with: name, application: application)
        }
    }

    private func _setupDatabase(with name: String, application: UIApplication) {

        let hashed = name.md5()
        
        guard dbPool == nil else {
            return
        }
        
        setupSecureDatabase(with: hashed, application: application)
    }
    
    private func setupSecureDatabase(with name: String, application: UIApplication) {
        let oldPassphrase = keychain.string(forKey: passphraseKey)
        let newPassphrase = makePassphrase(with: name)
        
        if databaseManager.setupDatabase(with: name,
                                         encryptionMode: .reencrypt(usingOld: oldPassphrase, new: newPassphrase),
                                         application: application) {
            keychain.set(newPassphrase, forKey: passphraseKey)
        }
    }
    
    private func makePassphrase(with name: String) -> String {
        let uuid = UUID().uuidString
        let size = uuid.count
        
        let centerIndex = uuid.index(uuid.startIndex, offsetBy: size / 2)
        let firstPart = uuid[uuid.startIndex..<centerIndex]
        let secondPart = uuid[centerIndex...]
        
        let passphrase = "\(firstPart)\(name)\(secondPart)"
        return passphrase.sha256()
    }
    
    // MARK: - Clear
    
    func clearStorage() {
        isolationQueue.sync { [weak self] in
            self?.databaseManager.clear()
            self?.keychain.clear()
        }
    }
    
    func wipeKeychain() {
        isolationQueue.sync { [weak self] in
            self?.keychain.clear()
        }
    }
}

extension StorageService: DBManagerProtocol {
    
    func fetch<T>(_ closure: (Database) throws -> T?) -> T? {
        return databaseManager.fetch(closure)
    }
    
    func fetch<T>(_ closure: (Database) throws -> [T]) -> [T] {
        return databaseManager.fetch(closure)
    }

    func fetchCount(_ closure: (Database) throws -> Int) -> Int {
        return databaseManager.fetchCount(closure)
    }

    func rowExists<T: Table>(in table: T.Type, where condition: String, arguments: StatementArguments?) -> Bool {
        return databaseManager.rowExists(in: table, where: condition, arguments: arguments)
    }
    
    func write(_ closure: (Database) throws -> Void) throws {
        try databaseManager.write(closure)
    }
    
    func perform(action: DatabaseAction, with model: DBModelConvertible) throws {
        try databaseManager.perform(action: action, with: model)
    }
    
    func perform(action: DatabaseAction, with model: DBModel) throws {
        try databaseManager.perform(action: action, with: model)
    }
    
    func perform(action: DatabaseAction, with models: [DBModelConvertible]) throws {
        try databaseManager.perform(action: action, with: models)
    }
    
    func perform(action: DatabaseAction, with models: [DBModel]) throws {
        try databaseManager.perform(action: action, with: models)
    }
}
