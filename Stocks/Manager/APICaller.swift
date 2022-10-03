//
//  APICaller.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 11..
//

import Foundation


/// Object to manage API calls
final class APICaller {
    
    ///Public singleton
    public static let shared = APICaller()
    
    ///The constant parts of the url based on the Finhub free API
    private struct Constants {
        static let day: TimeInterval = 24 * 3600
        static let apiKey: String = "API KEY HERE"
        static let sandboxApiKey: String = "SANDBOX KEY HERE"
        static let baseURL: String = "https://finnhub.io/api/v1//"
    }
    
    ///Private constructor
    private init() {}
    
    //MARK: - Public
    
    /// Search for a company
    /// - Parameters:
    ///   - query: Query String for a symbol or company name
    ///   - completion: Callback for result
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        request(url: url(for: .search, queryParams: ["q" : safeQuery]), expecting: SearchResponse.self, completion: completion)
        
    }
    
    //Get stock info
    
    //Search stocks
    
    /// Get news from Type
    /// - Parameters:
    ///   - type: Type can be company for symbols or top stories for general
    ///   - completion: Result callback
    public func news(for type: NewsViewController.`Type`, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        
        let today = Date()
        let oneWeekBack = today.addingTimeInterval(-(Constants.day * 7))
        
        switch type {
        case .topStories:
            request(url: url(for: .topStories, queryParams: ["category": "general"]), expecting: [NewsStory].self, completion: completion)
        case .company(let symbol):
            request(url: url(for: .companyNews, queryParams: ["symbol": symbol, "from": DateFormatter.newsDateFormatter.string(from: oneWeekBack), "to": DateFormatter.newsDateFormatter.string(from: today)]), expecting: [NewsStory].self, completion: completion)
        default:
            print("Error with API call: news func")
        }
        
        
    }
    
    /// Get market price data using url
    /// - Parameters:
    ///   - symbol: the given symbol for data
    ///   - numberOfDays: number of days back from today
    ///   - completion: result callback
    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void
    ) {
        
        let today = Date().addingTimeInterval(1*(Constants.day)) //BUG: the API caller doesnt work when this today is on a holiday or weekend day. Video misses this too
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        
        let url = url(for: .marketData, queryParams: [
            "symbol": symbol,
            "resolution": "1",
            "from": "\(Int(prior.timeIntervalSince1970))",
            "to": "\(Int(today.timeIntervalSince1970))"
        ])
        
        request(url: url, expecting: MarketDataResponse.self, completion: completion)
        
    }
    
    /// Gets financial metrics using url
    /// - Parameters:
    ///   - symbol: the given symbol for data
    ///   - completion: result callback
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void
    ) {
        let url = url(
            for: .financials,
            queryParams: ["symbol": symbol, "metric": "all"]
        )
        
        request(
            url: url,
            expecting: FinancialMetricsResponse.self,
            completion: completion
        )
        
    }
    
    
    //MARK: - Private
    
    ///API Endpoints
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    ///API errors
    private enum APIError: Error {
        case noDataReturned
        case invalidURL
    }
    
    /// Try to create url for endpoint
    /// - Parameters:
    ///   - endpoint: Endpoint to create for
    ///   - queryParams: Additional query arguments
    /// - Returns: returns an optional URL
    private func url(
        for endpoint: Endpoint,
        //queryParams: KeyValuePairs<String, String>
        //KeyValuePairs force the Dictionary to keep its original order but is slower
        queryParams: [String: String] = [:]
    ) -> URL? {
        var urlString = Constants.baseURL + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        //Add any paramenters
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        
        //Add unique token
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        //convert query items to suffix string
        
        let queryString = queryItems.map {"\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        
        urlString += "?" + queryString
        
        //print("\n\(urlString)\n")
        
        
        return URL(string: urlString)
    }
    
    
    /// Perform API call
    /// - Parameters:
    ///   - url: URL to hit
    ///   - expecting: Type we expect to decode data to
    ///   - completion: Result callback
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
            
        }
        
        task.resume()
        
    }
    
    
}
