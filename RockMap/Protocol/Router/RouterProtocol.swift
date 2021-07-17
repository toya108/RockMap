//
//  Router.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

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
