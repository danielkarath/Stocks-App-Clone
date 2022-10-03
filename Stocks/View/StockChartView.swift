//
//  StockChartView.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 17..
//

import UIKit
import Charts

///View to show price chart
final class StockChartView: UIView {
    
    ///Chart view viewModel
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }
    
    private let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        
        
        return chartView
    }()
    
    //MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    ///Reset the mini chart view
    func reset() {
        chartView.data = nil
    }
    
    /// Configure chart view
    /// - Parameter viewModel: view ViewModel
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()
        
        for (index, value) in viewModel.data.enumerated() {
            entries.append(
                
                .init(x: Double(index), y: value)
                
            )
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "7 days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.label?.removeAll()
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.colors = [NSUIColor(red: 165/256, green: 165/256, blue: 165/256, alpha: 1)]
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }
    
}
