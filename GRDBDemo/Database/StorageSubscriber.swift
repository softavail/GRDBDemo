
enum SubscribeType: Hashable {
    case identity
    case account(String?)
    case authProvider
}

protocol StorageSubscriber: Identifiable {
    func update(with changes: [StorageChange], type: SubscribeType)
}
