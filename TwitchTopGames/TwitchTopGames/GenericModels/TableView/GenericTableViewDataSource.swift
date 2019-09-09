//
//  GenericTableViewDataSource.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 05/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

protocol GenericTableViewDataSourcePrefetchingDelegate {
    func fetchNewData()
}

final class GenericTableViewDataSource<V, T: Searchable>: NSObject, UITableViewDataSourcePrefetching, UITableViewDataSource where V: BaseTableViewCell<T> {
    
    var genericPrefetchingDelegate: GenericTableViewDataSourcePrefetchingDelegate?
    private var models: [T] = []
    private var identifier: String?
    private let configureCell: CellConfiguration
    private let totalCount: Int?
    typealias CellConfiguration = (V, T?) -> V
    
    private var searchResults: [T] = []
    private var isSearchActive: Bool = false
    
    init(models: [T], identifier: String, totalForInifityScroll: Int? = nil,configureCell: @escaping CellConfiguration) {
        self.models = models
        self.identifier = identifier
        self.configureCell = configureCell
        self.totalCount = totalForInifityScroll
    }
    
    func updateModels(_ models: [T]) {
        self.models.append(contentsOf: models)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let total = totalCount {
            return isSearchActive ? searchResults.count : total
        }else {
            return isSearchActive ? searchResults.count : models.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let identifier = self.identifier else {
            fatalError("Could not deque cell with identifier")
        }
        guard let cell: V = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? V else {
            fatalError("Could not deque cell with identifier")
        }
        
        if isLoadingCell(for: indexPath) {
            return configureCell(cell, nil)
        } else {
            let model = getModelAt(indexPath)
            return configureCell(cell, model)
        }
        
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            genericPrefetchingDelegate?.fetchNewData()
        }
    }
    
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= models.count
    }
    
    private func getModelAt(_ indexPath: IndexPath) -> T {
        return isSearchActive ? searchResults[indexPath.item] :  models[indexPath.item]
    }
    
    private func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath] ,in tableView: UITableView) -> [IndexPath] {
        let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
    private func calculateIndexPathsToReload(from newModels: [T]) -> [IndexPath] {
        let startIndex = models.count - newModels.count
        let endIndex = startIndex + newModels.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
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








