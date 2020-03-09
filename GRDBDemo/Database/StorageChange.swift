
struct StorageChange {
    let kind: StorageChangeKind
    let entity: Any
}

enum StorageChangeKind {
    case insert
    case update
    case delete
}
