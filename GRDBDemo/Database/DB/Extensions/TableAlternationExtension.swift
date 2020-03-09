import GRDB

extension TableAlteration {
    
    @discardableResult
    func add(column: Describable, _ type: Database.ColumnType?) -> ColumnDefinition {
        return add(column: column.title, type)
    }
}
