import UIKit

class HorizontalImageListCollectionViewCell: UICollectionViewCell {
    let imageView = ZoomImagePresentableImageView(frame: .zero)

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

        contentView.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            self.imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(crudableImage: CrudableImage) {
        if let data = crudableImage.updateData {
            self.imageView.image = UIImage(data: data)
        } else {
            self.imageView.loadImage(url: crudableImage.image.url)
        }
    }
}
