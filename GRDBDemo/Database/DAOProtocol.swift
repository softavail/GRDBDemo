
protocol DAOProtocol {
    static var dbManager: DBManagerProtocol { get }
}

extension DAOProtocol {
    
    static var dbManager: DBManagerProtocol {
        return StorageService.sharedInstance
    }
    
}
