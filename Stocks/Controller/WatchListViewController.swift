//
//  ViewController.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 10..
//

import UIKit
import FloatingPanel

///ViewController to render user watchlist
final class WatchListViewController: UIViewController {
    
    ///Time ti optimize searching
    public var searchTimer: Timer?
    
    ///Timer for refreshing watchlist data
    private var refreshTimer = Timer()
    
    ///Floating News Panel using FloatingPanel pod
    private var panel: FloatingPanelController?
    
    ///Width to track change label width geometry
    static var maxChangeWidth: CGFloat = 0 
    
    /// Model
    private var watchlistMap: [String : [CandleStick]] = [:]
    
    
    /// ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    ///Main view to render user watchlist
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
    }()
    
    ///Observer for watchlist updates
    private var observer: NSObjectProtocol?
    
    //MARK: - Lifecycle
    
    ///Called when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "MainBackgroundColor")
        setUpSearchController()
        setUpTableView()
        fetchWatchlistData()
        setUpTitleView()
        setUpFloatingPanel()
        setUpObserver()
           
        refreshData()
        
        // Do any additional setup after loading the view.
    }
    
    ///Layout subviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        tableView.backgroundColor = UIColor(named: "MainBackgroundColor")
    }
    
    //MARK: - Private
    
    ///Refreshes watchlist data
    private func refreshData() {
        
        self.refreshTimer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true,
            block: {_ in
                
                
                self.setUpSearchController()
                self.setUpTableView()
                self.fetchWatchlistData()
                self.setUpTitleView()
                self.setUpFloatingPanel()
                self.setUpObserver()
                
                
                /*
                self.fetchWatchlistData()
                self.setUpObserver()
                */
        })
    }
    
    
    ///Sets up the observer for watchlist updates
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchWatchlistData()
            }
        )
    }
    
    
    /// Fetches watchlist models
    private func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist
        
        //Calls placeholder watchlist while fetching
        createPlaceholderViewModels()
        
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            
            //where watchlistMap[symbol] == nil
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
                
            }
            
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    
    /// Creates a placeholder watchlist that is displayed while fetching the real watchlist data
    private func createPlaceholderViewModels() {
        let symbols = PersistenceManager.shared.watchlist
        symbols.forEach { item in
            viewModels.append(
                .init(symbol: item,
                      companyName: UserDefaults.standard.string(forKey: item) ?? "Company",
                      price: "0.00",
                      changeColor: UIColor(named: "ThirdTextColor") ?? .systemGray,
                      changePercentage: "unch",
                      chartViewModel: .init(
                        data: [],
                        showLegend: false,
                        showAxis: false,
                        fillColor: .clear
                      )
                )
            )
        }
        tableView.reloadData()
        
    }
    
    
    
    /// Creates viewmodels from models
    private func createViewModels() {
        
        var viewModels = [WatchListTableViewCell.ViewModel]()
        let unknownCompany: String = "Company"
        
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = candleSticks.getChangePercentage()
            
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? unknownCompany,
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: (changePercentage < 0 ? UIColor(named: "MarketRed") : UIColor(named: "MarketGreen"))!,
                    changePercentage: .percentage(from: changePercentage), chartViewModel: .init(
                        data: candleSticks.reversed().map{ $0.close},
                        showLegend: false,
                        showAxis: false,
                        fillColor: (changePercentage < 0 ? UIColor(named: "MarketRed") : UIColor(named: "MarketGreen"))!
                    )
                )
            )
        }
        
        //print("\n\n\n\(viewModels)\n\n\n")
        
        //Alphabeticaly sorts the watchlist elements
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
    }
    
    /// Gets latest closing price
    /// - Parameter data: Collection of data
    /// - Returns: String
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        
        return String.formatted(number: closingPrice)
    }
    
    /// Sets up tableview
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /// Sets up floating news panel from floatingpanel pod
    private func setUpFloatingPanel() {
        let panel = FloatingPanelController(delegate: self)
        let appearance = SurfaceAppearance()
        let vc = NewsViewController(type: .topStories)
        
        panel.addPanel(toParent: self)
        panel.surfaceView.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
        panel.surfaceView.grabberHandle.barColor = UIColor.init(named: "ThirdTextColor") ?? .systemGray
        panel.set(contentViewController: vc)
        panel.track(scrollView: vc.tableView)
    }
    
    /// Sets up custom title view
    private func setUpTitleView() {
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))

        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width * 0.30, height: titleView.height*0.80))
        titleLabel.text = "Stocks"
        titleLabel.textColor = UIColor(named: "MainTextColor")
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        
        
        let developerLabel = UILabel(frame: CGRect(x: 10, y: titleLabel.bottom - 3, width: titleLabel.width - 10, height: titleView.height*0.20))
        developerLabel.textAlignment = .right
        developerLabel.text = "by Daniel Karath"
        developerLabel.textColor = UIColor(named: "SecondaryTextColor")
        developerLabel.font = .systemFont(ofSize: 8, weight: .regular)
        
        
        //titleView.addSubview(dateLabel)
        titleView.addSubview(developerLabel)
        titleView.addSubview(titleLabel)
        
        navigationItem.titleView = titleView
    }
    
    
    
    /// Setup search and result controllers
    private func setUpSearchController() {
        let resultVC = SearchResultViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        
    }
    
    
}

//MARK: - UISearchResultsUpdating


extension WatchListViewController: UISearchResultsUpdating{
    /// Updates search on key tap
    /// - Parameter searchController: Reference of the searchcontroller
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        //Optimize Timer so that not every keystroke call the API
        //Reset timer
        searchTimer?.invalidate()
        
        //Kick off new Timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            //Call API to search
            APICaller.shared.search(query: query) { result in
                
                switch result {
                case .success(let response):
                    //print(response.result)
                    
                    //Update resultController
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                }
                
            }
        })
        
        //print(query)
        
    }
}

//MARK: - SearchResultsViewControllerDelegate

extension WatchListViewController: SearchResultsViewControllerDelegate {
    /// Notify of search result selection
    /// - Parameter searchResult: The selected search result
    func didSelectSearchResult(searchResult: SearchResult) {
        //Here we present stock details for the selection
        
        //dismisses keyboard
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        //Vibrates when selecting
        HapticsManager.shared.vibrateForSelection()
        
        let vc = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navVc = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVc, animated: true)
    }
}

//MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    /// Gets floating panel state change
    /// - Parameter fpc: Reference of controller
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
        navigationItem.searchController?.searchBar.isHidden = fpc.state == .full
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.prefferedHeigh
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            //update persistance
            PersistenceManager.shared.removeToWatchlist(symbol: viewModels[indexPath.row].symbol)
            //update our viewModels
            viewModels.remove(at: indexPath.row)
            //delete a row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Vibrates when selecting
        HapticsManager.shared.vibrateForSelection()
        
        //open details for selection
        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? []
        )
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
}

//MARK: - WatchListTableViewCellDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
    /// Notify delegate of change of label width
    func didUpdateMaxWidth() {
        //Optimize by only refresh rows prior to the current row that changes the max width
        tableView.reloadData()
    }
}
