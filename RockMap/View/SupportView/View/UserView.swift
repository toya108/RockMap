//
//  UserView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import UIKit

@IBDesignable
class UserView: UIView {

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var registeredDateLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromNib()
    }

    private func loadFromNib() {
        let view = UINib(
            nibName: UserView.className,
            bundle: Bundle(for: type(of: self))
        ).instantiate(withOwner: self).first as! UIView

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        iconButton.layer.cornerRadius = 20
    }

    func configure(
        prefix: String = "登録者：",
        user: FIDocument.User?,
        registeredDate: Date? = nil
    ) {
        userNameLabel.text = prefix + (user?.name ?? "")

        if let photoURL = user?.photoURL {
            iconButton.imageView?.loadImage(url: photoURL)
        } else {
            iconButton.setImage(UIImage.AssetsImages.noimage, for: .normal)
        }

        if let registeredDate = registeredDate {
            let format = DateFormatter()
            format.timeStyle = .none
            format.dateStyle = .medium
            format.locale = .init(identifier: "ja_JP")
            registeredDateLabel.text = "登録日：" + format.string(from: registeredDate)
        } else {
            registeredDateLabel.isHidden = true
        }

        iconButton.addAction(
            .init { _ in

            }
            ,
            for: .touchUpInside
        )
    }

}
