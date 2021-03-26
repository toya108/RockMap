//
//  RockAnnotationDetailView.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/25.
//

import UIKit

class RockAnnotationDetailView: UIView {

    private var rock: FIDocument.Rock! {
        didSet {

        }
    }

    @IBOutlet weak var showDetailButton: UIButton!

    static func createView(rock: FIDocument.Rock) -> Self {
        let view = Self()
        view.rock = rock
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private func commonInit() {

        let nib = UINib(nibName: RockAnnotationDetailView.className, bundle: nil)

        guard
            let view = nib.instantiate(withOwner: self).first as? UIView
        else {
            return
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

}
