
import Foundation

final class StorageSubscriberReference {
    weak var subscriber: StorageSubscriber?
    
    init(_ subscriber: StorageSubscriber) {
        self.subscriber = subscriber
    }
}
