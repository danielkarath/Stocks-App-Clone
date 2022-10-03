//
//  StockDetailHeaderView.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 21..
//

import UIKit

///Header for stock details
final class StockDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    ///Metrics viewModels
    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    //Subviews
    
    
    ///ChartView
    private let chartView = StockChartView()
    
    ///CollectionView
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.init(named: "ThirdBackgroundColor")
        collectionView.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        //Register cells
        return collectionView
    }()
    
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubviews(chartView, collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height - 100)
        collectionView.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
    }
    
    
    //MARK: - Public
    
    /// Configure chart view
    /// - Parameters:
    ///   - chartViewModel: chart viewModel
    ///   - metricViewModels: Collection of metrics viewModels
    func configure(
        chartViewModel: StockChartView.ViewModel,
        metricViewModels: [MetricCollectionViewCell.ViewModel]
    ) {
        //update chart
        chartView.configure(with: chartViewModel)
        
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
        
    }
    
    
    //MARK: - Collectionview
    
    /*func numberOfSections(in collectionView: UICollectionView) -> Int {
     return 1
     }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MetricCollectionViewCell.identifier,
            for: indexPath
        ) as? MetricCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/4)
    }
}
