//
//  CourceRegisterColletionViewDelegate.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/14.
//

import UIKit

extension CourceRegisterViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard
            let section = SectionLayoutKind.allCases.any(at: indexPath.section),
            let item = snapShot.itemIdentifiers(inSection: section).any(at: indexPath.row)
        else {
            return
        }
        
        switch section {
        case .grade:
            
            guard
                case let .grade(grade) = item
            else {
                return
            }
            
            viewModel.grade = grade
            
        default:
            return
            
        }
    }
}
