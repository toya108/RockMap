import UIKit

class TextFieldColletionViewCell: UICollectionViewCell {
    let textField = UITextField()
    let stackView = UIStackView()
    let borderView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        contentView.addSubview(self.stackView)
        self.stackView.distribution = .fill
        self.stackView.spacing = 8
        self.stackView.axis = .vertical

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            self.stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            self.stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])

        [self.textField, self.borderView].forEach {
            stackView.addArrangedSubview($0)
        }

        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        self.borderView.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            self.borderView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    func configurePlaceholder(_ placeholder: String) {
        self.textField.placeholder = placeholder
    }
}
