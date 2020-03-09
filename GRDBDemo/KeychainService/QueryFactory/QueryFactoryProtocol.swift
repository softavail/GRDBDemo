protocol QueryFactoryProtocol {
    func makeQuery(for info: QueryInfo) -> KeychainQuery
    func makeAllClassesQuery() -> [KeychainQuery]
}
