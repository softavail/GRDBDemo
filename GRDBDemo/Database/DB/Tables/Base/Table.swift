
import GRDB

protocol Table {
    static var name: String { get }
    static func create(in db: Database) throws
}

protocol ExtendedTable: Table {
    associatedtype Column: Hashable, Describable
}

extension Table {
    
    static func createIfNotExists(in db: Database) throws {
        if try !db.tableExists(self) {
            try create(in: db)
        }
    }
    
    static func drop(in db: Database) throws {
        try db.drop(table: self)
    }
    
    static func alter(in db: Database, body: (TableAlteration) -> Void) throws {
        try db.alter(table: self, body: body)
    }
    
    static func rename(to newName: String, in db: Database) throws {
        try db.rename(table: self, to: newName)
    }
    
    static func hasColumns(_ columns: Set<Column>, in db: Database) throws -> Bool {
        return try db.hasColumns(columns, in: self)
    }
    
    static func allColumns(in db: Database) throws -> [String] {
        return try db.allColumns(in: self)
    }
}
