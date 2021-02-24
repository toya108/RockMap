//
//  ConfirmationButtonColletionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/20.
//

import UIKit

class ConfirmationButtonCollectionViewCell: UICollectionViewCell {
    
    let stackView = UIStackView()
    let cautionLabel = UILabel()
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    private func setupLayout() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        cautionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        cautionLabel.translatesAutoresizingMaskIntoConstraints = false
        cautionLabel.text = "※登録内容は他のユーザーに公開されます。"
        stackView.addArrangedSubview(cautionLabel)
        
        button.setTitle("　登録内容を確認する　", for: .normal)
        button.layer.cornerRadius = Resources.Const.UI.View.radius
        button.backgroundColor = UIColor.Pallete.primaryGreen
        button.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(button)
    }
    
    func configure(confirmationButtonTapped: @escaping () -> Void) {
        button.addAction(
            .init { _ in
                confirmationButtonTapped()
            },
            for: .touchUpInside
        )
    }
}
