import UIKit

class IconTextFieldCollectionViewCell: UICollectionViewCell {
    let iconImageView = UIImageView()
    let textField = UITextField()
    let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.iconImageView.tintColor = .gray

        contentView.addSubview(self.stackView)
        self.stackView.spacing = 8
        self.stackView.axis = .horizontal

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            self.stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8),
            self.stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            self.stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(self.iconImageView)
        NSLayoutConstraint.activate([
            self.iconImageView.heightAnchor.constraint(equalToConstant: 32),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 32),
        ])

        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(self.textField)
    }

    func configurePlaceholder(iconImage: UIImage, placeholder: String) {
        self.textField.placeholder = placeholder
        self.iconImageView.image = iconImage
    }
}
