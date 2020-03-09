
extension Collection {
    
    public func joinedByComma() -> String {
        return _joined(separator: ",")
    }
    
    public func joinedByCommaIfNotEmpty() -> String? {
        return joinedIfNotEmpty(separator: ",")
    }
    
    private func _joined(separator: String) -> String {
        return map { String(describing: $0) }.joined(separator: separator)
    }
    
    private func joinedIfNotEmpty(separator: String) -> String? {
        return isEmpty ? nil : _joined(separator: separator)
    }
}
