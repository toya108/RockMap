import UIKit

class LabelCollectionViewCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    func configure(text: String) {
        self.label.text = text
    }

    private func setupLayout() {
        contentView.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.numberOfLines = 0
        self.label.font = UIFont.systemFont(ofSize: 14)
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.label.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}
