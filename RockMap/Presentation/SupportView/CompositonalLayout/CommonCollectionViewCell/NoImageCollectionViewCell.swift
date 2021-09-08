import UIKit

class NoImageCollectionViewCell: UICollectionViewCell {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        backgroundColor = .systemGroupedBackground
        layer.cornerRadius = 8
        addSubview(self.label)
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
        self.label.text = "画像は未投稿です。"
        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.centerYAnchor.constraint(equalTo: centerYAnchor),
            self.label.leftAnchor.constraint(equalTo: leftAnchor),
            self.label.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
