//
//  PersistenceManager.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 07. 11..
//

import Foundation

///Object to manage saved caches
final class PersistenceManager {
    ///Singleton
    static let shared = PersistenceManager()
    
    ///Reference to user defaults
    private let userDefaults: UserDefaults = .standard
    
    ///Constants
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    ///Private constructor
    private init() {}
    
    //MARK: - Public
    
    ///Get user watchlist
    public var watchlist: [String] {
        
        if !hasOnboarded {
            userDefaults.setValue(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        
        
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    /// Check if watchlist contains item
    /// - Parameter symbol: Symbol to check
    /// - Returns: Boolean
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol) 
    }
    
    /// Add a symbol to watchlist
    /// - Parameters:
    ///   - symbol: Symbol to add
    ///   - companyName: Company name for the symbol beeing added
    public func addToWatchlist(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    /// Remove item from watchlist
    /// - Parameter symbol: symbol to be removed
    public func removeToWatchlist(symbol: String) {
        
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)
        
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchlistKey)
        
    }
    
    //MARK: - Private
    
    ///Check if user has been onboarded
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }
    
    ///Set up a default watchlist
    private func setUpDefaults() {
        let map: [String: String] = [
            "DIS" : "The Walt Disney Company",
            "EA" : "Electronic Arts Inc.",
            "FTNT" : "Fortinet",
            "MNST" : "Monster Bewerage Corp.",
            "PYPL" : "Paypal Inc.",
            "SBUX" : "Starbucks Corp.",
            "ZG" : "Zillow Group Corp"
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
        
    }
    
}
