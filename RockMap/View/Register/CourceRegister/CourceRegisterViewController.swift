//
//  CourceRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit
import Combine

class CourceRegisterViewController: UIViewController, ColletionViewControllerProtocol {
    
    var collectionView: UICollectionView!
    var viewModel: CourceRegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColletionView(layout: .init())
    }

    static func createInstance(
        viewModel: CourceRegisterViewModel
    ) -> CourceRegisterViewController {
        let instance = CourceRegisterViewController()
        instance.viewModel = viewModel
        return instance
    }
    
}
