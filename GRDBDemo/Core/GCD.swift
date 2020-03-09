
import Foundation

typealias GCDBlock = () -> Void
typealias GCDCompletionBlock = () -> Void

extension DispatchQueue {
    
    class var global: DispatchQueue {
        return dispatchGetDefaultQueue()
    }
    
}

private var workItems: [String: DispatchWorkItem] = [:]
func dispatchAsyncMainThrotlle(key: String, seconds: TimeInterval, firstImmediate: Bool = false, block: @escaping GCDBlock) {
    var workItem = workItems[key]
    
    if workItem == nil && firstImmediate {
        workItem = DispatchWorkItem(block: block)

        DispatchQueue.main.async(execute: workItem!)
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            workItems.removeValue(forKey: key)
        })
    } else {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: {
            block()
            workItems.removeValue(forKey: key)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: workItem!)
    }
    
    workItems[key] = workItem
}

func dispatchGetDefaultQueue() -> DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
}

func dispatchGetBackgroundQueue() -> DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
}

func dispatchAsyncMain(_ block: @escaping GCDBlock) {
    DispatchQueue.main.async(execute: block)
}

func dispatchAsyncDefault(_ block: @escaping GCDBlock) {
    dispatchGetDefaultQueue().async(execute: block)
}

func dispatchAsyncBackground(_ block: @escaping GCDBlock) {
    dispatchGetBackgroundQueue().async(execute: block)
}

func dispatchAsyncMainAfter(_ seconds: Double, block: @escaping GCDBlock) {
    let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime, execute: block)
}

// block will be called in another thread asynchronously
// completion will be called
func dispatchAsync(block: @escaping GCDBlock, andRunCompletionInMain completion: @escaping GCDCompletionBlock) {
    dispatchGetDefaultQueue().async {
        block()
        
        dispatchAsyncMain(completion)
    }
}
