import UIKit

class AnnotationHeaderCollectionViewCell: UICollectionViewCell {
    let headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    private func configure() {
        addSubview(self.headerLabel)
        self.headerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.headerLabel.adjustsFontForContentSizeCategory = true
        NSLayoutConstraint.activate([
            self.headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            self.headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            self.headerLabel.rightAnchor.constraint(equalTo: rightAnchor),
            self.headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.headerLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    }

    func configure(
        title: String
    ) {
        self.headerLabel.text = title
    }
}
