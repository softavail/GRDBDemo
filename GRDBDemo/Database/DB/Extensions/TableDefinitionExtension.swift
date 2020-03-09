import GRDB

extension TableDefinition {
    
    @available(*, deprecated, message: "Use `func column(_ column: Column, _ type: Database.ColumnType? = nil) -> ColumnDefinition` instead")
    @discardableResult
    func column(_ desc: Describable, _ type: Database.ColumnType? = nil) -> ColumnDefinition {
        return column(desc.title, type)
    }
    
    @discardableResult
    func column(_ column: Column, _ type: Database.ColumnType? = nil) -> ColumnDefinition {
        return self.column(column.name, type)
    }
}
