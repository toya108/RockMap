import UIKit

class SegmentedControllCollectionViewCell: UICollectionViewCell {
    let segmentedControl = UISegmentedControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    private func setupLayout() {
        self.segmentedControl.selectedSegmentTintColor = UIColor.Pallete.primaryGreen
        self.segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white as Any],
            for: .selected
        )
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.segmentedControl)

        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        NSLayoutConstraint.activate([
            self.segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor),
            self.segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            self.segmentedControl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }

    func configure(items: [String], selectedIndex: Int?) {
        items.enumerated().forEach { index, title in
            segmentedControl.insertSegment(withTitle: title, at: index, animated: true)
        }

        guard
            let index = selectedIndex
        else {
            return
        }

        self.segmentedControl.selectedSegmentIndex = index
    }
}
