//
//  MetricCollectionViewCell.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 21..
//

import UIKit

///Financial metrics collectionView Cell
final class MetricCollectionViewCell: UICollectionViewCell {
    
    ///Identifier for Metric CollectionViewCell
    static let identifier = "MetricCollectionViewCell"
    
    ///Metric table cell viewModel
    struct ViewModel {
        let name: String
        let value: String
    }
    
    
    //MARK: - Private
    
    ///NameLabel for financial metric
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "ThirdTextColor")
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    ///ValueLabel for the given financial metric
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "SecondaryTextColor")
        label.font = .systemFont(ofSize: 15, weight: .medium)
        
        return label
    }()
    
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubviews(nameLabel, valueLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        valueLabel.sizeToFit()
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 3, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3, y: 0, width: valueLabel.width, height: contentView.height)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    /// Configure view
    /// - Parameter viewModel: view ViewModel
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name + ":"
        valueLabel.text = viewModel.value
    }
    
}
