//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 11..
//

import UIKit
import SafariServices

///Viewcontroller to show stock details
final class StockDetailsViewController: UIViewController {

    //MARK: - Properties
    
    
    ///Stock symbol
    private let symbol: String
    
    ///Company full name
    private let companyName: String
    
    ///Collection of price data
    private var candleStickData: [CandleStick]
    
    ///Primary view
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        
        return table
    }()
    
    ///Collection of news stories
    private var stories: [NewsStory] = []
    
    ///Company financial metrics
    private var metrics: Metrics?
    
    //MARK: - Init
    
    init(
        symbol: String,
        companyName: String,
        candleStickData: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor(named: "MainBackgroundColor")
        title = companyName
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    //MARK: - Private
    
    
    /// Sets up close button
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    
    /// Handles close button tap
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// Sets up primary tableview
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
    }
    
    /// Fetches financial metrics
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        //fetch candlesticks if needed
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
                
            }
        }
        
        //fetch financial metrics
        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    /// Fetches news stories for given type
    private func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
         
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
            
        }
        
    }
    
    
    /// Renders chart and metrics
    private func renderChart() {
        //ChartViewmodel and financial metrics viewmodel
        let headerView = StockDetailHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: (view.width * 0.7) + 100)
        )
        
        headerView.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
        //headerView.backgroundColor = .link
        
        //Configure func called here
        var viewModels: [MetricCollectionViewCell.ViewModel] = []

        if let metrics = metrics {
            viewModels.append(.init(name: "52W high", value: "\(metrics.annualWeekHigh)"))
            viewModels.append(.init(name: "52W low", value: "\(metrics.annualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "avg. volume", value: "\(metrics.tenDayAverageTradingVolume)"))


        }
        let change = candleStickData.getChangePercentage()
        headerView.configure(
            chartViewModel: .init(data: candleStickData.reversed().map { $0.close }, showLegend: true,
                showAxis: true,
                fillColor: ((change < 0 ? UIColor(named: "MarketRed") : UIColor(named: "MarketGreen")) ?? .darkGray)
            ),
            metricViewModels: viewModels
        )
        tableView.tableHeaderView = headerView
    }
    
}

//MARK: - UITableViewDelegate and UITableViewDataSource

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(), souldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.prefferedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Vibrates lightly when selecting
        HapticsManager.shared.vibrateForSelection()
        
        guard let url = URL(string: stories[indexPath.row].url) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
}

//MARK: - NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        
        //Vibrates when adding stock to watchlist
        HapticsManager.shared.vibrate(for: .success)
        
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchlist(
            symbol: symbol,
            companyName: companyName
        )
        
        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your Watchlist",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
