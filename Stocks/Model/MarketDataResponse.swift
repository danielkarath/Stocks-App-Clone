//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 15..
//

import Foundation

///Market data response
struct MarketDataResponse: Codable {
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let low: [Double]
    let volume: [Int]
    let status: String
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case high = "h"
        case low = "l"
        case volume = "v"
        case status = "s"
        case timestamps = "t"
    }
    
    ///Converts market data to an array of candle stick models
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()
        
        for index in 0..<open.count {
            result.append(
                .init(
                    date: Date(timeIntervalSince1970: timestamps[index]),
                    open: open[index],
                    close: close[index],
                    high: high[index],
                    low: low[index],
                    volume: volume[index])
            )
        }
        let sortedData = result.sorted(by: { $0.date > $1.date})
        return sortedData
    }
    
}

///Model to represent data for a single day 
struct CandleStick {
    let date: Date
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let volume: Int
    
}
