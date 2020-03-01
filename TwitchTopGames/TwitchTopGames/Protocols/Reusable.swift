//
//  Reusable.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 05/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable {}

/// MARK: - UITableView

extension Reusable where Self: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
extension UICollectionViewCell: Reusable {}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ :T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not deque cell with identifier")
        }
        return cell
    }
}

