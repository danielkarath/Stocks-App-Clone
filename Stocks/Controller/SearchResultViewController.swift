//
//  SearchResultViewController.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 11..
//

import UIKit

///Delegate for search results
protocol SearchResultsViewControllerDelegate: AnyObject {
    /// Notify delegate of selection
    /// - Parameter searchResult: Selected result
    func didSelectSearchResult(searchResult: SearchResult)
}

///Viewcontroller to show search results
final class SearchResultViewController: UIViewController {

    ///Delegate to get events
    weak var delegate: SearchResultsViewControllerDelegate?
    
    ///Collection of search results
    private var results: [SearchResult] = []
    
    ///Primary view
    private let tableView: UITableView = {
        let table = UITableView()
        //Register Cell
        table.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        table.isHidden = true
        
        return table
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    //MARK: - Private
    
    
    /// Sets up tableview
    private func setUpTable() {
        
        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(named: "MainBackgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    //MARK: - Public
    
    
    /// Update results on viewcontroller
    /// - Parameter results: Collection of new search results
    public func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
    
    
}

//MARK: - UITableViewDelegate and UITableViewDataSource

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        
        let model = results[indexPath.row]
        
        cell.backgroundColor = UIColor(named: "MainBackgroundColor")
        cell.textLabel?.text = model.symbol
        cell.detailTextLabel?.text = model.description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]

        delegate?.didSelectSearchResult(searchResult: model)
    }
}
