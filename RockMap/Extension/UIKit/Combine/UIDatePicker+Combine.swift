//
//  UIDatePicker+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/13.
//

import UIKit
import Combine

public extension UIDatePicker {

    var datePublisher: AnyPublisher<Date, Never> {
        Publishers
            .ControlProperty(
                control: self,
                events: .defaultValueEvents,
                keyPath: \.date
            )
            .eraseToAnyPublisher()
    }
    
}
