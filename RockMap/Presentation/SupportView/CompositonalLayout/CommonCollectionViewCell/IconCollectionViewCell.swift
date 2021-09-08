import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    let stackView = UIStackView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    var isSelecting: Bool = false {
        didSet {
            if self.isSelecting {
                layer.borderColor = UIColor.Pallete.primaryGreen.cgColor
                layer.borderWidth = 1.5
                self.titleLabel.textColor = UIColor.Pallete.primaryGreen
                self.titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
            } else {
                layer.borderColor = UIColor.gray.cgColor
                layer.borderWidth = 1
                self.titleLabel.textColor = .gray
                self.titleLabel.font = .systemFont(ofSize: 17)
            }
        }
    }

    private func setupLayout() {
        layer.cornerRadius = 8

        self.stackView.axis = .horizontal
        self.stackView.alignment = .fill
        self.stackView.spacing = 4
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            self.stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            self.stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 8
            ),
            self.stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8)
        ])

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(self.iconImageView)

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = .gray
        self.stackView.addArrangedSubview(self.titleLabel)

        NSLayoutConstraint.activate([
            self.iconImageView.widthAnchor.constraint(equalToConstant: 24),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    func configure(icon: UIImage? = nil, title: String) {
        if
            let icon = icon
        {
            self.iconImageView.image = icon
        } else {
            self.stackView.arrangedSubviews.first(where: { $0 === iconImageView })?
                .removeFromSuperview()
        }

        self.titleLabel.text = title
    }
}
