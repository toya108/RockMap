//
//  UISegmentedControl+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/13.
//

import UIKit
import Combine

public extension UISegmentedControl {

    var selectedSegmentIndexPublisher: AnyPublisher<Int, Never> {
        Publishers.ControlProperty(
            control: self,
            events: .defaultValueEvents,
            keyPath: \.selectedSegmentIndex
        )
        .eraseToAnyPublisher()
    }

}

