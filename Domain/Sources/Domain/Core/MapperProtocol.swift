
public protocol MapperProtocol {
    associatedtype From
    associatedtype To
    func map(from other: From) -> To
    init()
}
