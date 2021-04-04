//
//  Router.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/31.
//

import UIKit

protocol RouterProtocol {

    associatedtype Destination: DestinationProtocol

    func route(
        to destination: Destination,
        from context: UIViewController
    )

}

protocol DestinationProtocol {}
