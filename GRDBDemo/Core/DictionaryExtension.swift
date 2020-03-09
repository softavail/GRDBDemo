
extension Dictionary {
    
    func mergingUniquingFirst(with other: [Key: Value]) -> [Key: Value] {
        return (try? merging(other, uniquingKeysWith: uniquingUsingFirst)) ?? self
    }
    
    mutating func mergeUniquingFirst(with other: [Key: Value]) {
        try? merge(other, uniquingKeysWith: uniquingUsingFirst)
    }
    
    mutating func mergeUniquingOther(with other: [Key: Value]) {
        try? merge(other, uniquingKeysWith: uniquingUsingOther)
    }
    
    private func uniquingUsingFirst(value: Value, secondValue: Value) throws -> Value {
        return value
    }
    
    private func uniquingUsingOther(value: Value, secondValue: Value) throws -> Value {
        return secondValue
    }
}
