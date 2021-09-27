import UIKit

class SegmentedControllCollectionViewCell: UICollectionViewCell {
    let segmentedControl = UISegmentedControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
        self.configureControls()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
        self.configureControls()
    }

    private func configureControls() {
        let lithologyNames = Entity.Rock.Lithology.allCases.map(\.name)

        lithologyNames.enumerated().forEach {
            segmentedControl.insertSegment(withTitle: $1, at: $0, animated: true)
        }
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
            self.segmentedControl.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    func set(index: Int) {
        self.segmentedControl.selectedSegmentIndex = index
    }
}
