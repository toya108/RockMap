import UIKit

protocol RouterProtocol {
    associatedtype Destination: DestinationProtocol
    associatedtype ViewModel: ViewModelProtocol

    var viewModel: ViewModel! { get set }

    init(viewModel: ViewModel)

    func route(
        to destination: Destination,
        from context: UIViewController
    )
}

protocol DestinationProtocol {}
