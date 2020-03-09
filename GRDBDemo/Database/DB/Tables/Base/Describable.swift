
import GRDB

protocol Describable {
    var title: String { get }
}

extension Describable {
    
    var title: String {
        return String(describing: self)
    }
}
