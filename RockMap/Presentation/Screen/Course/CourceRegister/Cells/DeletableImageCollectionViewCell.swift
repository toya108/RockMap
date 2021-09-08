import UIKit

class DeletableImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let deleteButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        self.imageView.layer.cornerRadius = Resources.Const.UI.View.radius
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill

        contentView.addSubview(self.imageView)

        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])

        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.setImage(UIImage.SystemImages.xmarkCircleFill, for: .normal)
        self.deleteButton.tintColor = .white
        self.imageView.addSubview(self.deleteButton)
        NSLayoutConstraint.activate([
            self.deleteButton.heightAnchor.constraint(equalToConstant: 44),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 44),
            self.deleteButton.topAnchor.constraint(equalTo: self.imageView.topAnchor),
            self.deleteButton.rightAnchor.constraint(equalTo: self.imageView.rightAnchor),
        ])
    }

    func configure(
        crudableImage: CrudableImage,
        deleteButtonTapped: @escaping () -> Void
    ) {
        if let data = crudableImage.updateData {
            self.imageView.image = UIImage(data: data)
        } else {
            self.imageView.loadImage(url: crudableImage.image.url)
        }

        self.deleteButton.addAction(
            .init { _ in
                deleteButtonTapped()
            },
            for: .touchUpInside
        )
    }
}
