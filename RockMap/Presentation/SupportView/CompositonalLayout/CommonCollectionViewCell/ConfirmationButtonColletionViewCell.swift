import UIKit

class ConfirmationButtonCollectionViewCell: UICollectionViewCell {
    let stackView = UIStackView()
    let cautionLabel = UILabel()
    let button = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.stackView.axis = .vertical
        self.stackView.alignment = .leading
        self.stackView.spacing = 16
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16
            ),
            self.stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])

        self.cautionLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        self.cautionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cautionLabel.text = "※登録内容は他のユーザーに公開されます。"
        self.stackView.addArrangedSubview(self.cautionLabel)

        self.button.layer.cornerRadius = Resources.Const.UI.View.radius
        self.button.backgroundColor = UIColor.Pallete.primaryGreen
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(self.button)
        NSLayoutConstraint.activate([
            self.button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func configure(confirmationButtonTapped: @escaping () -> Void) {
        self.button.addActionForOnce(
            .init { _ in
                confirmationButtonTapped()
            },
            for: .touchUpInside
        )
    }

    func configure(title: String) {
        self.button.setTitle(title, for: .normal)
    }
}
