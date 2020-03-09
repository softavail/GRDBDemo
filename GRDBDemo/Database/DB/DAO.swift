
class DAO<T: DBModel> {
    let dbManager = StorageService.sharedInstance
    
    func fetch<U: TypedQueryRequestMakeable>(with maker: U, kind: DBModelFetchingKind = .constructed) -> [T] where U.Model == T {
        return dbManager.fetch { db in
            return try maker.makeTypedRequest().fetchAll(db, kind: kind)
        }
    }
}
