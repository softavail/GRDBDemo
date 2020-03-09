
import Foundation

protocol StorageObserver: class {
    var subscribers: [SubscribeType: [StorageSubscriberReference]] { get set }
    
    var isolationQueue: DispatchQueue { get }
    
    func register(subscriber: StorageSubscriber, type: SubscribeType)
    func unregister(subscriber: StorageSubscriber, type: SubscribeType)
    func unregister(subscribers type: SubscribeType)
    
    func notify(with changes: [StorageChange], type: SubscribeType)
}

extension StorageObserver {
    
    func register(subscriber: StorageSubscriber, type: SubscribeType) {
        isolationQueue.async { [weak self, weak subscriber] in
            guard let self = self, let subscriber = subscriber else {
                return
            }
            let reference = StorageSubscriberReference(subscriber)
            if var subs = self.subscribers[type] {
                subs.append(reference)
                self.subscribers[type] = subs
            } else {
                self.subscribers[type] = [reference]
            }
        }
    }
    
    func register(subscriber: StorageSubscriber, types: [SubscribeType]) {
        types.forEach {
            register(subscriber: subscriber, type: $0)
        }
    }
    
    func unregister(subscriber: StorageSubscriber, type: SubscribeType) {
        isolationQueue.async { [weak self, weak subscriber] in
            guard let self = self, let subscriber = subscriber else {
                return
            }
            self.subscribers[type] = self.subscribers[type]?.filter { $0.subscriber != nil && $0.subscriber?.id != subscriber.id }
        }
    }
    
    func unregister(subscribers type: SubscribeType) {
        isolationQueue.async { [weak self] in
            self?.subscribers.removeValue(forKey: type)
        }
    }
    
    func unregister(subscriber: StorageSubscriber) {
        subscribers.keys.forEach {
            unregister(subscriber: subscriber, type: $0)
        }
    }
    
    func notify(with changes: [StorageChange], type: SubscribeType) {
        isolationQueue.sync { [weak self] in
            
            guard let subscribers = self?.subscribers[type] else {
                return
            }
            
            for subscriberRef in subscribers {
                dispatchAsyncMain {
                    subscriberRef.subscriber?.update(with: changes, type: type)
                }
            }
        }
    }
}
