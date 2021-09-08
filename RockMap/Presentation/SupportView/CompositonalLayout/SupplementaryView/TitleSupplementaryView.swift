import UIKit

class TitleSupplementaryView: UICollectionReusableView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    private func configure() {
        addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.adjustsFontForContentSizeCategory = true
        NSLayoutConstraint.activate([
            self.label.topAnchor.constraint(equalTo: topAnchor),
            self.label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        self.label.font = UIFont.preferredFont(forTextStyle: .headline)
    }

    func setSideInset(_ inset: CGFloat) {
        NSLayoutConstraint.activate([
            self.label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            self.label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset),
        ])
    }
}
