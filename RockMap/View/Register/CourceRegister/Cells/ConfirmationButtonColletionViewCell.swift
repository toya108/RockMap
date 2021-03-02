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
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
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
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
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
