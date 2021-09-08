import UIKit

class TitleCollectionViewCell: UICollectionViewCell {
    let stackView = UIStackView()
    let iconImageView = UIImageView()
    let titleLabel = UILabel()
    let supplementalyLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.stackView.axis = .horizontal
        self.stackView.spacing = 8
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.stackView)
        NSLayoutConstraint.build {
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor)
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.tintColor = .black
        self.stackView.addArrangedSubview(self.iconImageView)
        self.stackView.addArrangedSubview(self.titleLabel)

        NSLayoutConstraint.build {
            iconImageView.heightAnchor.constraint(equalToConstant: 36)
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        }

        self.titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        self.supplementalyLabel.font = .systemFont(ofSize: 24, weight: .bold)
        self.stackView.addArrangedSubview(self.supplementalyLabel)
    }

    func configure(
        icon: UIImage? = nil,
        title: String,
        supplementalyTitle: String = ""
    ) {
        if let icon = icon {
            self.iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            self.iconImageView.isHidden = false
        } else {
            self.iconImageView.isHidden = true
        }
        self.titleLabel.text = title
        self.supplementalyLabel.text = supplementalyTitle
    }
}
