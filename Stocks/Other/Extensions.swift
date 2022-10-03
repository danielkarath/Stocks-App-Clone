//
//  Extensions.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 20..
//

import UIKit

//Notification

extension Notification.Name {
    ///Notification for when a symbol is added to our watchlist
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}



//Number formatter

extension NumberFormatter {
    
    ///Formats percentage style numbers
    static let precentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter
    }()
    
    ///Formats decimal numbers
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter
    }()
}



//Image View

extension UIImageView {
    
    /// Sets image from remote url
    /// - Parameter url: URL to fetch from
    func setImage(with url: URL?) {
        guard let url = url else {
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.sync {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

//MARK: - String

extension String {
    
    /// Creates string from timeinterval
    /// - Parameter timeInterval: timeinterval since 1970
    /// - Returns: formatted string
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    /// Converts Double to percentage formatted String
    /// - Parameter double: the Double to be formatted
    /// - Returns: formatted String
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.precentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    /// Converts Double to decimal formatted String
    /// - Parameter number: the Double to be formatted
    /// - Returns: formatted String
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    ///Capitalizes the first chars of String
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    
}


//MARK: - DateFormatters

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
}


//MARK: - Add Subview

extension UIView {
    
    /// Adds multiple subviews
    /// - Parameter views: collection of subviews
    func addSubviews(_ views: UIView...) {
        views.forEach{
            addSubview($0)
        }
    }
    
    
}


//MARK: - Framing extensions

extension UIView {
    /// Width of view
    var width: CGFloat{
        frame.size.width
    }
    
    ///Height of view
    var height: CGFloat{
        frame.size.height
    }
    
    ///Left edge of view
    var left: CGFloat{
        frame.origin.x
    }
    
    ///Right edge of view
    var right: CGFloat{
        left + width
    }
    
    ///Top edge of view
    var top: CGFloat{
        frame.origin.y
    }
    
    ///bottom edge of view
    var bottom: CGFloat{
        top + height
    }
    
}


//MARK: - CandleStick Sorting and Percentage

extension Array where Element == CandleStick {
    func getChangePercentage() -> Double {
        let latestDate = self[0].date
        guard let latestClose = self.first?.close,
              let priorClose = self.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
            return 0
        }
        
        let diff = (1 - priorClose/latestClose)
        //let diffSign = diff > 0 ? "+" : ""
        //print("Symbol: \(symbol) | Current Date: \(latestDate) close: \(latestClose) | prior close : \(priorClose) | change: \(diffSign)\(diff)%")
         
        return diff
    }
}
