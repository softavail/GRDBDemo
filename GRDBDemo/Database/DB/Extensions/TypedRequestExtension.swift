
import GRDB

enum DBModelFetchingKind {
    case plain
    case constructed
}

extension FetchRequest where RowDecoder: DBModel {
    
    func fetchAllConstructed(_ db: Database) throws -> [RowDecoder] {
        return try fetchAll(db, kind: .constructed)
    }
    
    func fetchOneConstructed(_ db: Database) throws -> RowDecoder? {
        return try fetchOne(db, kind: .constructed)
    }
    
    func fetchAll(_ db: Database, kind: DBModelFetchingKind) throws -> [RowDecoder] {
        let models = try self.fetchAll(db)
        if kind == .constructed {
            try models.construct(db)
        }
        return models
    }
    
    func fetchOne(_ db: Database, kind: DBModelFetchingKind) throws -> RowDecoder? {
        let model = try self.fetchOne(db)
        if kind == .constructed {
            try model?.construct(db)
        }
        return model
    }
}
