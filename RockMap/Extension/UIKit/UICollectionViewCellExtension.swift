import UIKit

extension UICollectionViewCell {
    func executeSelectAnimation() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.alpha = 0.5
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.1,
                    animations: {
                        self.alpha = 1
                    }
                )
            }
        )
    }
}
