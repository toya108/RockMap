//
//  SegmentedControllCollectionViewCell.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/13.
//

import UIKit

class SegmentedControllCollectionViewCell: UICollectionViewCell {
    
    let segmentedControl = UISegmentedControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        segmentedControl.selectedSegmentTintColor = UIColor.Pallete.primaryGreen
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white as Any], for: .selected)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            segmentedControl.rightAnchor.constraint(equalTo: contentView.rightAnchor)
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
        
        segmentedControl.selectedSegmentIndex = index
    }
}
