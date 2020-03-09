
import GRDB

struct RosterRelatedQueryArgs<T: DBModel>: CompositeQueryArgs {
    let rosterId: Int64
    let args: AnyQueryArgs<T>
    
    init(rosterId: Int64) {
        self.init(rosterId: rosterId, args: AnyQueryArgs<T>())
    }
    
    init(rosterId: Int64, args: AnyQueryArgs<T>) {
        self.rosterId = rosterId
        self.args = args
    }
    
    func makeTypedRequest() -> QueryInterfaceRequest<T> {
        return args.makeTypedRequest().filter(Column.rosterId == rosterId)
    }
}
