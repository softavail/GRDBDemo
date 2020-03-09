
import GRDB

extension Column: CustomStringConvertible, Hashable {
    
    public var description: String {
        return name
    }
    
    public var hashValue: Int {
        return name.hashValue
    }
    
    public static func == (lhs: Column, rhs: Column) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Column {
    
    func asString(table: Table.Type) -> String {
        return asString(tableName: table.name)
    }
    
    func asString(tableName: String) -> String {
        return "\(tableName).\(self)"
    }
}
