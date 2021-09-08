//
//  TouchableScrollView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/04.
//

import UIKit

/// touchedBeganを検出可能なScrollView
/// - note: extensionではなぜか検出できなかったのでUIScrollViewを継承したクラスを用意しています。
final class TouchableScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
    }
}

class TouchableColletionView: UICollectionView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.touchesBegan(touches, with: event)
    }
}
