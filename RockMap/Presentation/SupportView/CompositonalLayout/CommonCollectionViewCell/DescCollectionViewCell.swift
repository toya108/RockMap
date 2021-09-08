import UIKit

class DescCollectionViewCell: UICollectionViewCell {
    let descLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        addSubview(self.descLabel)
        self.descLabel.numberOfLines = 0
        self.descLabel.textColor = .darkGray
        self.descLabel.font = UIFont.preferredFont(forTextStyle: .body)
        self.descLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.descLabel.topAnchor.constraint(equalTo: topAnchor),
            self.descLabel.leftAnchor.constraint(equalTo: leftAnchor),
            self.descLabel.rightAnchor.constraint(equalTo: rightAnchor),
            self.descLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
