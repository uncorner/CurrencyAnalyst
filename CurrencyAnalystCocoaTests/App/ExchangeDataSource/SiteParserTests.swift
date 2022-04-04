//
//  SiteParserTests.swift
//  CurrencyAnalystTests
//
//  Created by denis on 03.04.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation
import XCTest
@testable import CurrencyAnalystCocoa

class SiteParserTests: XCTestCase {
    
    private func loadHtml(siteUrl: String) -> String {
        var resultHtml: String = ""
        
        if let url = URL(string: siteUrl) {
            guard let html = try? String(contentsOf: url, encoding: .utf8) else {
                XCTFail("Fail to load HTML")
                return resultHtml
            }
            
            resultHtml = html
        }
        
        return resultHtml
    }
    
    func testGetBankDetail() {
        let parsedUrl = "https://kovalut.ru/alfa-bank/moskva/"
        let html = loadHtml(siteUrl: parsedUrl)
        let url = URL(string: parsedUrl)
        let parser = SiteParser()
        let result: BankDetailResult
        do {
            result = try parser.getBankDetail(html: html, url: url!)
        }
        catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        XCTAssertNotNil(result.mapUrl)
        print(result.mapUrl?.absoluteURL ?? "absoluteURL is nil")
        
        XCTAssertTrue(result.dataTables.count > 0)
        
        // table 0
        let table = result.dataTables[0]
        assertNotEmpty(table.header)
        
        XCTAssertTrue(table.rows.count > 0)
        let row = table.rows[0]
        XCTAssertEqual("Адрес:", row.header)
        assertNotEmpty(row.data!)
    }
    
    private func assertNotEmpty(_ value: String) {
        if value.isEmptyOrWhitespace() {
            XCTFail("value is empty or whitespace")
        }
    }
    
    func testGetOfficeGeoDatas() {
        let html = loadHtml(siteUrl: "https://kovalut.ru/alfa-bank/moskva/na-karte/")
        let parser = SiteParser()
        
        let result: [OfficeGeoData]
        do {
            result = try parser.getOfficeGeoDatas(html: html)
        }
        catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        XCTAssertNotNil(result)
        XCTAssert(result.count > 0)
    }
    
    func testGetCities() {
        let html = loadHtml(siteUrl: "https://kovalut.ru/cities.htm")
        let parser = SiteParser()

        let cities: [City]
        do {
            cities = try parser.getCities(html: html)
        }
        catch {
            XCTFail(error.localizedDescription)
            return
        }
            
        XCTAssertTrue(cities.count >= 1116)
        let city = cities.first!
        XCTAssertEqual("Абаза", city.name)
        XCTAssertEqual("/bankslist.php?kod=1902", city.url)
        XCTAssertEqual("/bankslist.php?kod=1902", city.id)
    }
    
    func testGetExchanges() {
        let html = loadHtml(siteUrl: "https://kovalut.ru/kurs/moskva")
        
        let parser = SiteParser()
        let result: ExchangeListResult
        
        do {
            result = try parser.getExchanges(html: html)
        }
        catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        XCTAssertNotNil(result)
        
        XCTAssertNotNil(result.cbInfo)
        XCTAssertNotNil(result.cbInfo.usdExchangeRate)
        XCTAssert(result.cbInfo.usdExchangeRate.rate > 0)
        XCTAssert(result.cbInfo.usdExchangeRate.rateStr.isEmpty == false)
        XCTAssertNotNil(result.cbInfo.euroExchangeRate)
        XCTAssert(result.cbInfo.euroExchangeRate.rate > 0)
        XCTAssert(result.cbInfo.euroExchangeRate.rateStr.isEmpty == false)
        
        XCTAssertNotNil(result.exchanges)
        XCTAssertTrue(result.exchanges.count > 0)
        
        for exchange in result.exchanges {
            XCTAssertNotNil(exchange)
            
            XCTAssert(exchange.usdExchange.strAmountBuy.isEmpty == false)
            XCTAssert(exchange.usdExchange.strAmountSell.isEmpty == false)
            XCTAssert(exchange.euroExchange.strAmountBuy.isEmpty == false)
            XCTAssert(exchange.euroExchange.strAmountSell.isEmpty == false)
            
            XCTAssert(exchange.usdExchange.amountBuy >= 0)
            XCTAssert(exchange.usdExchange.amountSell >= 0)
            XCTAssert(exchange.euroExchange.amountBuy >= 0)
            XCTAssert(exchange.euroExchange.amountSell >= 0)
            
            if exchange.usdExchange.isBestBuy {
                XCTAssertTrue(exchange.usdExchange.amountBuy > 0)
                print("\(exchange.bankName): usdExchange.isBestBuy: \(exchange.usdExchange.isBestBuy)")
            }
            if exchange.usdExchange.isBestSell {
                XCTAssertTrue(exchange.usdExchange.amountSell > 0)
                print("\(exchange.bankName): usdExchange.isBestSell: \(exchange.usdExchange.isBestSell)")
            }
            if exchange.euroExchange.isBestBuy {
                XCTAssertTrue(exchange.euroExchange.amountBuy > 0)
                print("\(exchange.bankName): euroExchange.isBestBuy: \(exchange.euroExchange.isBestBuy)")
            }
            if exchange.euroExchange.isBestSell {
                XCTAssertTrue(exchange.euroExchange.amountSell > 0)
                print("\(exchange.bankName): euroExchange.isBestSell: \(exchange.euroExchange.isBestSell)")
            }
            
            XCTAssert(exchange.updatedTime.isEmpty == false)
            
            if exchange.bankUrl == nil {
                print("\(exchange.bankName): empty bank url is found")
            }
            if exchange.bankLogoUrl == nil {
                print("\(exchange.bankName): empty bank Logo url is found")
            }
        }
        
        var bestItems = result.exchanges.filter({
            $0.usdExchange.isBestBuy == true
        })
        print("usdExchange.isBestBuy \(bestItems.count)")
        
        bestItems = result.exchanges.filter({
            $0.usdExchange.isBestSell == true
        })
        print("usdExchange.isBestSell \(bestItems.count)")
        
        bestItems = result.exchanges.filter({
            $0.euroExchange.isBestBuy == true
        })
        print("euroExchange.isBestBuy \(bestItems.count)")
        
        bestItems = result.exchanges.filter({
            $0.euroExchange.isBestSell == true
        })
        print("euroExchange.isBestSell \(bestItems.count)")
    }
    
}
