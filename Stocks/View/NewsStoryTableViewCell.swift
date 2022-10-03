//
//  NewsStoryTableViewCell.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 13..
//

import UIKit
import SDWebImage

///News story tableView cell
final class NewsStoryTableViewCell: UITableViewCell {
    
    ///Cell identifier
    static let identifier = "NewsStoryTableViewCell"
    
    ///Preffered height of newsStory tableView cell
    static let preferredHeight: CGFloat = 140
    
    ///Cell viewModel
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
        
    }
    
    ///Label for news Source name
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor.init(named: "ThirdTextColor")
        return label
    }()
    
    ///Label for news Headline
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    ///Label for news Date
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.init(named: "ThirdTextColor")
        label.font = .systemFont(ofSize: 11, weight: .light)
        return label
    }()
    
    ///imageView for news Image
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.init(named: "SecondaryBackgroundColor")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "ThirdBackgroundColor")
        //contentView.backgroundColor = .clear
        backgroundColor = .clear
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height / 1.44
        storyImageView.frame = CGRect(x: contentView.width - (imageSize + 10), y: (contentView.height - imageSize) / 2, width: imageSize, height: imageSize)
        
        //Layout Labels
        let availableWidth: CGFloat = contentView.width - (separatorInset.left + imageSize + 15)
        dateLabel.frame = CGRect(x: separatorInset.left, y: contentView.height - 40, width: availableWidth, height: 40)
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left, y: 4, width: availableWidth, height: sourceLabel.height)
        
        headlineLabel.frame = CGRect(x: separatorInset.left, y: sourceLabel.bottom + 1, width: availableWidth, height: contentView.height - (sourceLabel.bottom + dateLabel.height + 10))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        imageView?.image = nil
    }
    
    /// Configure view
    /// - Parameter viewModel: view ViewModel
    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        
        let sampleImages = [UIImage(named: "NewsImage1"),UIImage(named: "NewsImage2"),UIImage(named: "NewsImage3"),UIImage(named: "NewsImage4")]
        let randomImage = sampleImages.randomElement()!
        if viewModel.imageURL == nil {
            storyImageView.image = randomImage
        } else {
            storyImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        }
        storyImageView.sd_setImage(with: viewModel.imageURL, completed: nil)

        //Manually set image below
        //storyImageView.setImage(with: viewModel.imageURL)
        //image
    }
    
    

}
