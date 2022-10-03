//
//  FinancialMetricsResponse.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 21..
//

import Foundation

///Metrics response for API
struct FinancialMetricsResponse: Codable {
    let metric: Metrics
}

///Financial metrics
struct Metrics: Codable {
    let tenDayAverageTradingVolume: Float
    let annualWeekHigh: Double
    let annualWeekLow: Double
    let annualWeekLowDate: String
    let annualWeekPriceReturnDaily: Float
    let beta: Float
    
    enum CodingKeys: String, CodingKey {
        case tenDayAverageTradingVolume = "10DayAverageTradingVolume"
        case annualWeekHigh = "52WeekHigh"
        case annualWeekLow = "52WeekLow"
        case annualWeekLowDate = "52WeekLowDate"
        case annualWeekPriceReturnDaily = "52WeekPriceReturnDaily"
        case beta = "beta"
    }
}
