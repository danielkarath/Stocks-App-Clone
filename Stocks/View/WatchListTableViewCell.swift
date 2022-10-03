//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 17..
//

import UIKit

///Delegate to notify of cell events
protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

///TableCell for Watchlist item
final class WatchListTableViewCell: UITableViewCell {
    
    ///Cell identifier
    static let identifier: String = "WatchListTableViewCell"
    
    ///Delegate
    weak var delegate: WatchListTableViewCellDelegate?
    
    ///Preffered height of watchlist cell
    static let prefferedHeigh: CGFloat = 60.0
    
    ///Watchlist tableView cell viewModel
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String //formatted
        let changeColor: UIColor //Red, Green or Greyish
        let changePercentage: String //formatted
        let chartViewModel: StockChartView.ViewModel
    }
    
    ///Symbol Label
    private let symbolLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "MainTextColor")
        return label
    }()
    
    ///Company Label
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(named: "ThirdTextColor")
        return label
    }()
    
    ///Price Label
    private let priceLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(named: "MainTextColor")
        return label
    }()
    
    
    ///Change in price label
    private let changeLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "MainTextColorWhite")
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    
    ///MiniChart View
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        //chart.backgroundColor = .link
        
        
        return chart
    }()
    
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor(named: "MainBackgroundColor")
        addSubviews(
            symbolLabel,
            nameLabel,
            miniChartView,
            priceLabel,
            changeLabel
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.height
        )
        
        nameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: nameLabel.width,
            height: nameLabel.height
        )
        
        let currentWidth = max(
            max(priceLabel.width, changeLabel.width),
            WatchListViewController.maxChangeWidth
            )
        
        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(
            x: contentView.width - (currentWidth + 10),
            y: (contentView.height - (priceLabel.height + changeLabel.height + priceLabel.height/5))/2,
            width: currentWidth,
            height: priceLabel.height
        )
        
        changeLabel.frame = CGRect(
            x: contentView.width - (currentWidth + 10),
            y: priceLabel.bottom + priceLabel.height/5,
            width: currentWidth,
            height: changeLabel.height
        )
        
        miniChartView.frame = CGRect(
            x: priceLabel.left - (contentView.width / 3 + 5),
            y: 6,
            width: contentView.width / 3,
            height: contentView.height - 12
        )
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    /// Configure view
    /// - Parameter viewModel: view ViewModel
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName.capitalized
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
