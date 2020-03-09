
import GRDB

extension ColumnDefinition {
    
    @discardableResult
    func references(_ table: String, column: Column, onDelete deleteAction: Database.ForeignKeyAction? = nil, onUpdate updateAction: Database.ForeignKeyAction? = nil, deferred: Bool = false) -> ColumnDefinition {
        return self.references(
            table,
            column: column.name,
            onDelete: deleteAction,
            onUpdate: updateAction,
            deferred: deferred)
    }
}
