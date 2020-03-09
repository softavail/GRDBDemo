
import GRDB

extension Database {
    
    // MARK: - Table info
    
    func infoFor(tableName: String) throws -> [Row] {
        return try Row.fetchAll(self, sql: "PRAGMA table_info(?)", arguments: [tableName])
    }
    
    // MARK: - Columns
    
    func allColumns(tableName: String) throws -> [String] {
        return try infoFor(tableName: tableName)
            .compactMap { $0["name"] }
    }
    
    func hasColumns(_ columns: Set<String>, tableName: String) throws -> Bool {
        let rows = try infoFor(tableName: tableName)
        let tableColumns = Set<String>(rows.compactMap { $0["name"] })
        return !columns.intersection(tableColumns).isEmpty
    }
    
    func hasColumns<T: Table>(_ columns: Set<Column>, in table: T.Type) throws -> Bool {
        return try hasColumns(Set<String>(columns.compactMap { $0.name }), tableName: T.name)
    }
    
    func allColumns<T: Table>(in table: T.Type) throws -> [String] {
        return try allColumns(tableName: table.name)
    }
    
    func columnType(tableName: String, column: Column) throws -> ColumnType? {
        let columnRow = try infoFor(tableName: tableName).first { $0["name"] == column.name }
        return columnRow?["type"].map { ColumnType($0) }
    }
    
    func columnType<T: Table>(table: T.Type, column: Column) throws -> ColumnType? {
        return try columnType(tableName: table.name, column: column)
    }
    
    
    // MARK: - Table
    
    func clearTables(_ tableNames: [String]) throws {
        try tableNames.forEach { name in
            try execute(sql: "delete from ?", arguments: [name])
        } 
        try? execute(sql: "delete from sqlite_sequence")
    }
    
    func tableExists<T: Table>(_ table: T.Type) throws -> Bool {
        return try tableExists(T.name)
    }
    
    func create<T: Table>(_ table: T.Type, body: (TableDefinition) -> Void) throws {
        try create(table: T.name, body: body)
    }
    
    func rename<T: Table>(table: T.Type, to newName: String) throws {
        try rename(table: T.name, to: newName)
    }
    
    func alter<T: Table>(table: T.Type, body: (TableAlteration) -> Void) throws {
        try alter(table: T.name, body: body)
    }
    
    func drop<T: Table>(table: T.Type) throws {
        try drop(table: T.name)
    }
    
    // MARK: - Recreate
    
    typealias SQLCreator = (_ sourceTableName: String, _ destinationTableName: String) -> String
    
    func recreate(table: Table.Type,
                  sharedColumns columns: Set<Column> = [],
                  insertCreator: SQLCreator? = nil,
                  sqlCreator: SQLCreator? = nil) throws {
        
        let tempTableName = "\(table.name)_temp"
        let tableName = table.name
        
        try rename(table: tableName, to: tempTableName)
        
        try table.create(in: self)
        
        let insertSql = insertCreator?(tempTableName, tableName) ?? insertSQL(columns: columns, from: tempTableName, into: tableName)
        let extraSql = sqlCreator?(tempTableName, tableName) ?? ""
        let sql = "\(insertSql); \(extraSql)"
        
        try execute(sql: sql)
        
        try drop(table: tempTableName)
    }
    
    private func insertSQL(columns: Set<Column>, from: String, into: String) -> String {
        let columnsString = columns
            .map { "\"\($0)\"" }
            .joinedByComma()
        
        let intoColumnsString = columns.isEmpty ? "" : "(\(columnsString))"
        let selectColumnsString = columns.isEmpty ? "*" : columnsString
        
        return """
        INSERT INTO \(into) \(intoColumnsString)
        SELECT \(selectColumnsString) FROM \(from)
        """
    }
}
