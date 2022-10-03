//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 07..
//

import UIKit

///Delegate to notify of header events
protocol NewsHeaderViewDelegate: AnyObject {
    /// Notifies user of tapped headder button
    /// - Parameter headerView: Reference of headerView
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

///TableView header for news
final class NewsHeaderView: UITableViewHeaderFooterView {
    
    ///Header identifier
    static let identifier = "NewsHeaderView"
    ///Ideal height of the headerView
    static let prefferedHeight: CGFloat = 70
    ///Delegate instance of events
    weak var delegate: NewsHeaderViewDelegate?
    
    ///Viewmodel for header view
    struct ViewModel {
        let title: String
        let souldShowAddButton: Bool
    }
    
    
    //MARK: - Private
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = UIColor(named: "MainTextColor")
        
        return label
    }()
    
    
     let button: UIButton = {
        let button = UIButton()
        button.setTitle("add Watchlist", for: .normal)
        button.backgroundColor = UIColor(named: "MainElementColor")
        button.setTitleColor(UIColor(named: "MainTextColor"), for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    //MARK: - init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "SecondaryBackgroundColor")
        //contentView.alpha = 1.0
        contentView.addSubviews(label, button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    ///Handles button tap
    @objc private func didTapButton() {
        
        //Call delegate
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.width-28, height: contentView.height)
        button.sizeToFit()
        button.frame = CGRect(x: contentView.width - button.width - 16, y: (contentView.height - button.height)/2, width: button.width + 8, height: button.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    
    /// Configure view
    /// - Parameter viewModel: view ViewModel
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.souldShowAddButton
        
    }
    
    
}
