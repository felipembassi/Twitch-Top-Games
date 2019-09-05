//
//  GenericCollectionViewDataSource.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 05/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

final class GenericCollectionViewDataSource<V, T: Searchable>: NSObject, UICollectionViewDataSource where V: BaseCollectionViewCell<T> {
    
    private var models: [T]
    private let configureCell: CellConfiguration
    typealias CellConfiguration = (V, T) -> V
    
    private var searchResults: [T] = []
    private var isSearchActive: Bool = false
    
    init(models: [T], configureCell: @escaping CellConfiguration) {
        self.models = models
        self.configureCell = configureCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearchActive ? searchResults.count : models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: V = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let model = getModelAt(indexPath)
        return configureCell(cell, model)
    }
    
    private func getModelAt(_ indexPath: IndexPath) -> T {
        return isSearchActive ? searchResults[indexPath.item] :  models[indexPath.item]
    }
    
    /// external function for searching
    func search(query: String) {
        isSearchActive = !query.isEmpty
        searchResults = models.filter {
            let queryToFind = $0.query.range(of: query, options: NSString.CompareOptions.caseInsensitive)
            return (queryToFind != nil)
        }
    }
}








