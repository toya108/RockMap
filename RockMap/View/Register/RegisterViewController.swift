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
        guard
            AuthManager.isLoggedIn
        else {
            showOKAlert(
                title: "登録できません。",
                message: "岩の登録にはログインが必要です。マイページ画面から一度ログアウトしていただき、ログインしてから再度お試し下さい。"
            )
            
            return
        }
        
        guard
            let vc = UIStoryboard(name: RockRegisterViewController.className, bundle: nil).instantiateInitialViewController()
        else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func didCourseRegisterButtonTapped(_ sender: UIButton) {
        guard
            AuthManager.isLoggedIn
        else {
            showOKAlert(
                title: "登録できません。",
                message: "課題の登録にはログインが必要です。マイページ画面から一度ログアウトしていただき、ログインしてから再度お試し下さい。"
            )
            
            return
        }
        
        guard
            let vc = UIStoryboard(name: RockDetailViewController.className, bundle: nil).instantiateInitialViewController()
        else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupLayout() {
        navigationItem.title = "岩/課題を登録する"
        
        [rockRegisterButton, courseRegisterButton].forEach {
            $0?.layer.cornerRadius = Resources.Const.UI.View.radius
            $0?.layer.shadowRadius = Resources.Const.UI.Shadow.radius
            $0?.layer.shadowOffset = .init(width: 8, height: 8)
            $0?.layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        }
    }
}
