
import GRDB

enum DatabaseAction {
    case save
    case delete
    case update
    case updateColumns(Set<String>)
}

protocol DBManagerProtocol {
    
    // MARK: - Fethching
    func fetch<T>(_ closure: (Database) throws -> T?) -> T?
    func fetch<T>(_ closure: (Database) throws -> [T]) -> [T]
    func fetchCount(_ closure: (Database) throws -> Int) -> Int
    func rowExists<T: Table>(in table: T.Type, where condition: String, arguments: StatementArguments?) -> Bool
    
    // MARK: - Writing
    func write(_ closure: (Database) throws -> Void) throws
    
    // MARK: - Perform Actions
    func perform(action: DatabaseAction, with model: DBModelConvertible) throws
    func perform(action: DatabaseAction, with model: DBModel) throws

    func perform(action: DatabaseAction, with models: [DBModelConvertible]) throws
    func perform(action: DatabaseAction, with models: [DBModel]) throws
    
}
