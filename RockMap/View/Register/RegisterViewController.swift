//
//  RegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/31.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var rockRegisterButton: UIButton!
    @IBOutlet weak var courseRegisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    @IBAction func didRockRegisterButtonTapped(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: RockRegisterViewController.className, bundle: nil).instantiateInitialViewController() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didCourseRegisterButtonTapped(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: RockDetailViewController.className, bundle: nil).instantiateInitialViewController() else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLayout() {
        navigationItem.title = "岩/課題を登録する"
        
        [rockRegisterButton, courseRegisterButton].forEach {
            $0?.layer.cornerRadius = 8
            $0?.layer.shadowRadius = 8
            $0?.layer.shadowOffset = .init(width: 8, height: 8)
            $0?.layer.shadowOpacity = 0.3
        }
    }
}
