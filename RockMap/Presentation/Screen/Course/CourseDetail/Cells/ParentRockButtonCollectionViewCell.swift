import UIKit

class ParentRockButtonCollectionViewCell: UICollectionViewCell {
    let stackView = UIStackView()
    let iconImageView = UIImageView()
    let rockButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.axis = .horizontal
        self.stackView.spacing = 8
        contentView.addSubview(self.stackView)
        NSLayoutConstraint.build {
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor)
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        }

        self.iconImageView.tintColor = .black
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage.AssetsImages.rockFill
        self.stackView.addArrangedSubview(self.iconImageView)
        NSLayoutConstraint.build {
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
            iconImageView.widthAnchor.constraint(equalToConstant: 36)
        }

        self.rockButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        self.rockButton.setTitleColor(.black, for: .normal)
        self.stackView.addArrangedSubview(self.rockButton)
    }

    func configure(
        title: String,
        didTap: @escaping () -> Void
    ) {
        self.rockButton.setTitle(title, for: .normal)
        self.rockButton.addActionForOnce(
            .init { _ in didTap() },
            for: .touchUpInside
        )
    }
}
