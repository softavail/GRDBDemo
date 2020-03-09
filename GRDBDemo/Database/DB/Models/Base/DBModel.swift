
import GRDB

protocol DBModel: PersistableRecord, FetchableRecord {
    
    func saveAggregate(_ db: Database) throws
    
    @discardableResult
    func deleteAggregate(_ db: Database) throws -> Bool
    
    func construct(_ db: Database) throws
}

extension DBModel {
    
    func saveAggregate(_ db: Database) throws {
        try save(db)
    }
    
    @discardableResult
    func deleteAggregate(_ db: Database) throws -> Bool {
        try delete(db)
        return false
    }
    
    func construct(_ db: Database) throws {}
}

extension Array where Element: DBModel {
    
    func construct(_ db: Database) throws {
        try forEach { try $0.construct(db) }
    }
}
