//
//  StocksTests.swift
//  StocksTests
//
//  Created by Daniel Karath on 2021. 09. 04..
//

import XCTest
@testable import Stocks

class StocksTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSomething() {
        let number = 1
        let string = "1"
        XCTAssertEqual(number, Int(string))
    }
    
    func testCandleStickDataConversion() {
        let doubles: [Double] = Array(repeating: 12.2, count: 10)
        var timestamps: [TimeInterval] = []
        for x in 0..<12 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(x)).timeIntervalSince1970
            timestamps.append(interval)
        }
        let ints: [Int] = Array(repeating: 8, count: 10)

        timestamps.shuffle()
        
        let marketData = MarketDataResponse(
            open: doubles,
            close: doubles,
            high: doubles,
            low: doubles,
            volume: ints,
            status: "success",
            timestamps: timestamps
        )
        
        let candleSticks = marketData.candleSticks
        XCTAssertEqual(candleSticks.count, marketData.open.count)
        XCTAssertEqual(candleSticks.count, marketData.close.count)
        XCTAssertEqual(candleSticks.count, marketData.high.count)
        XCTAssertEqual(candleSticks.count, marketData.low.count)
        
        //Verify sort
        let dates = candleSticks.map { $0.date}
        for x in 0..<dates.count-1 {
            let current = dates[x]
            let next = dates[x+1]
            XCTAssertTrue(current > next, "\(current) date should be greater than \(next)")
        }
    }
}
