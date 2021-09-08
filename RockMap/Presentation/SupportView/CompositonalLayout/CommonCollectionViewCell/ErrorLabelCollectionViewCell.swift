import UIKit

class ErrorLabelCollectionViewCell: UICollectionViewCell {
    let errorLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    func configure(message: String) {
        self.errorLabel.text = "※" + message
    }

    private func setupLayout() {
        self.errorLabel.numberOfLines = 0
        contentView.addSubview(self.errorLabel)
        self.errorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        self.errorLabel.textColor = UIColor.Pallete.primaryPink
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.errorLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.errorLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}
