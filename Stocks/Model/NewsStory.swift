//
//  NewsStory.swift
//  Stocks
//
//  Created by Daniel Karath on 2021. 08. 08..
//

import Foundation

///Represent news story
struct NewsStory: Codable {
    
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
