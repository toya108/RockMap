
public protocol MapperProtocol {
    associatedtype From
    associatedtype To
    func map(from other: From) -> To
    func reverse(to other: To) -> From
    init()
}
