//
//  TextViewExtension.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/03.
//

import UIKit
import Combine

extension UITextView {
    var textDidChangedPublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default
            .publisher(for: UITextView.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
