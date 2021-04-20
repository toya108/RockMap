//
//  MyPageRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import UIKit

struct MyPageRouter: RouterProtocol {
    
    typealias Destination = DestinationType
    typealias ViewModel = MyPageViewModel

    enum DestinationType: DestinationProtocol {
        case hoge
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: DestinationType,
        from context: UIViewController
    ) {

    }

}
