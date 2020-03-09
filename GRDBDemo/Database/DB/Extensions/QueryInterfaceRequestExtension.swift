import GRDB

extension QueryInterfaceRequest {
    
    func performIfValueExists<V>(
        _ value: V?,
        closure: (QueryInterfaceRequest, V) -> QueryInterfaceRequest) -> QueryInterfaceRequest {
        
        guard let value = value else {
            return self
        }
        
        return closure(self, value)
    }
}
