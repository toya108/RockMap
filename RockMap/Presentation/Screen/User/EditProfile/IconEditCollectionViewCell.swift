
import Auth
import UIKit

class IconEditCollectionViewCell: UICollectionViewCell {
    let stackView = UIStackView()
    let imageView = UIImageView()
    let deleteButton = UIButton()
    let editButton = UIButton()

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
        self.stackView.distribution = .fill
        self.stackView.alignment = .center
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.spacing = 16
        contentView.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])

        self.imageView.isUserInteractionEnabled = true
        self.imageView.layer.cornerRadius = Resources.Const.UI.View.radius
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = 44
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.borderColor = UIColor.darkGray.cgColor

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(self.imageView)

        NSLayoutConstraint.activate([
            self.imageView.heightAnchor.constraint(equalToConstant: 88),
            self.imageView.widthAnchor.constraint(equalToConstant: 88)
        ])

        self.editButton.translatesAutoresizingMaskIntoConstraints = false
        self.editButton.backgroundColor = UIColor.Pallete.primaryGreen
        self.editButton.setImage(UIImage.SystemImages.cameraFill, for: .normal)
        self.editButton.setTitle(" アイコン編集 ", for: .normal)
        self.editButton.layer.cornerRadius = 8
        self.editButton.tintColor = .white
        self.stackView.addArrangedSubview(self.editButton)
        self.editButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.backgroundColor = .darkGray
        self.deleteButton.setTitle(" リセット ", for: .normal)
        self.deleteButton.layer.cornerRadius = 8
        self.deleteButton.tintColor = .white
        self.stackView.addArrangedSubview(self.deleteButton)
        self.deleteButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    func configure(image: CrudableImage) {
        if let data = image.updateData {
            self.imageView.image = UIImage(data: data)
        } else if let url = image.image.url {
            self.imageView.loadImage(url: url)
        }
    }
}
