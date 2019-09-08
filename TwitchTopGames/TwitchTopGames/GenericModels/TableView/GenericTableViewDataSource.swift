//
//  GenericTableViewDataSource.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 05/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

final class GenericTableViewDataSource<V, T: Searchable>: NSObject, UITableViewDataSource where V: BaseTableViewCell<T> {
    
    private var models: [T]
    private var identifier: String?
    private let configureCell: CellConfiguration
    typealias CellConfiguration = (V, T) -> V
    
    private var searchResults: [T] = []
    private var isSearchActive: Bool = false
    
    init(models: [T], identifier: String, configureCell: @escaping CellConfiguration) {
        self.models = models
        self.identifier = identifier
        self.configureCell = configureCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? searchResults.count : models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let identifier = self.identifier else {
            fatalError("Could not deque cell with identifier")
        }
        guard let cell: V = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? V else {
            fatalError("Could not deque cell with identifier")
        }
        
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








