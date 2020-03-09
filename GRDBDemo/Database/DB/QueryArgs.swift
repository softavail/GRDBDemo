
import GRDB

protocol QueryArgs {
    var limit: Int? { get }
    var offset: Int? { get }
    var orderingTerms: [SQLOrderingTerm]? { get }
}

protocol TypedQueryRequestMakeable {
    associatedtype Model: DBModel
    func makeTypedRequest() -> QueryInterfaceRequest<Model>
}

protocol CompositeQueryArgs: TypedQueryRequestMakeable {
    // TODO: add filter func...
    var args: AnyQueryArgs<Model> { get }
}

typealias QueryFilter<T> = (QueryInterfaceRequest<T>) -> QueryInterfaceRequest<T>

struct AnyQueryArgs<T: DBModel>: QueryArgs, TypedQueryRequestMakeable {
    let limit: Int?
    let offset: Int?
    let orderingTerms: [SQLOrderingTerm]?
    
    private(set) var filters: [QueryFilter<T>] = []

    init(limit: Int? = nil,
                offset: Int? = nil,
                orderingTerms: [SQLOrderingTerm]? = nil,
                filters: [QueryFilter<T>] = []) {
        self.limit = limit
        self.offset = offset
        self.orderingTerms = orderingTerms
        self.filters = filters
    }
    
    init(args: QueryArgs, filters: [QueryFilter<T>] = []) {
        self.init(
            limit: args.limit,
            offset: args.offset,
            orderingTerms: args.orderingTerms)
    }
    
    func filter(_ filter: @escaping QueryFilter<T>) -> AnyQueryArgs<T> {
        var filters = self.filters
        filters.append(filter)
        return AnyQueryArgs<T>(args: self, filters: filters)
    }
    
    func makeTypedRequest() -> QueryInterfaceRequest<T> {
        var query = T.all()
            .performIfValueExists(limit) { $0.limit($1, offset: offset) }
            .performIfValueExists(orderingTerms) { $0.order($1) }

        filters.forEach { filter in
            query = filter(query)
        }

        return query
    }
}
