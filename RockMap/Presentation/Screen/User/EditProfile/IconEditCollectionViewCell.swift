
import Auth
import UIKit

class IconEditCollectionViewCell: UICollectionViewCell {

    let stackView = UIStackView()
    let imageView = UIImageView()
    let deleteButton = UIButton()
    let editButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 16
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])

        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = Resources.Const.UI.View.radius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 44
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.darkGray.cgColor

        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 88),
            imageView.widthAnchor.constraint(equalToConstant: 88)
        ])

        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.backgroundColor = UIColor.Pallete.primaryGreen
        editButton.setImage(UIImage.SystemImages.cameraFill, for: .normal)
        editButton.setTitle(" アイコン編集 ", for: .normal)
        editButton.layer.cornerRadius = 8
        editButton.tintColor = .white
        stackView.addArrangedSubview(editButton)
        editButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.backgroundColor = .darkGray
        deleteButton.setTitle(" リセット ", for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.tintColor = .white
        stackView.addArrangedSubview(deleteButton)
        deleteButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    func configure(image: CrudableImage) {
        if let data = image.updateData {
            imageView.image = UIImage(data: data)
        } else if let url = image.image.url {
            imageView.loadImage(url: url)
        }
    }
}
