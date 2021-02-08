//
//  RockMapNavigationBar.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/29.
//

import UIKit

final class RockMapNavigationBar: UINavigationBar {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundImage = UIGraphicsImageRenderer.init(size: .init(width: 1, height: 1)).image { context in
            UIColor.white.setFill()
            context.fill(.init(origin: .init(x: 0, y: 0), size: .init(width: 1, height: 1)))
        }
        appearance.shadowImage = UIImage()

        // Large Title 用
        scrollEdgeAppearance = appearance
        // 通常の NavigationBar 用
        standardAppearance = appearance
        
        barTintColor = .white
        tintColor = .black
        
        layer.shadowColor = Resources.Const.UI.Shadow.color
        layer.shadowRadius = Resources.Const.UI.Shadow.radius
        layer.shadowOpacity = Resources.Const.UI.Shadow.opacity
        layer.shadowOffset = .init(width: 0, height: 2)
        
        backIndicatorImage = UIImage.AssetsImages.back
        backIndicatorTransitionMaskImage = UIImage.AssetsImages.back
    }
}
