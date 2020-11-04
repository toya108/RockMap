//
//  UITextFieldExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import UIKit
import Combine

extension UITextField {
    var textDidChangedPublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
