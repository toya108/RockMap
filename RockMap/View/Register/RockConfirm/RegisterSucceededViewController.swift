//
//  RegisterSucceededViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/01/12.
//

import UIKit

class RegisterSucceededViewController: UIViewController {}

extension RegisterSucceededViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController
    ) -> Bool {
        return false
    }
}
