//
//  SiteParser.swift
//  CurrencyAnalyst
//
//  Created by denis on 26.03.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation
import SwiftSoup
import CurrencyAnalystCommon

class SiteParser: ExchangeDataSource {
    
    func getBankDetail(html: String, url: URL) throws -> BankDetailResult {
        
            let doc: Document = try SwiftSoup.parseBodyFragment(html)
            // body
            let body = doc.body()
            
            // #maket > section > div:nth-child(6) > article:nth-child(2)
            let table = try body?.select(".plain-bank-content article table.bankshow").first()
            if let tableNode = table {
                let rowNodes = try tableNode.select("tr")
                var officeDataTables: [DataTable] = []
                var officeDataTable: DataTable = DataTable()
                
                for rowNode in rowNodes {
                    if rowNode.hasClass("br-head") {
                        var headerText = try rowNode.select("td").text().trimming()
                        officeDataTable = DataTable()
                        
                        if isNamelessOffice(inputStr: headerText) {
                            headerText += " Офис"
                        }
                        officeDataTable.header = headerText
                        officeDataTables.append(officeDataTable)
                    }
                    
                    let thNode = try rowNode.select("th").first()
                    let thText = try thNode?.text()
                    
                    guard let strongThText = thText else {continue}
                    var datas: [String] = []
                    
                    let subtableNode = try rowNode.select("td table").first()
                    if let subtable = subtableNode {
                        let subDatas = try parseSubtable(tableElement: subtable)
                        datas.append(contentsOf: subDatas)
                    }
                    else {
                        let tdNodes = try rowNode.select("td")
                        
                        let textList = tdNodes.map({ (value: Element) -> String? in
                            return try? value.text()
                        }).filter({ (value: String?) -> Bool in
                            return value != nil && value!.isEmptyOrWhitespace() == false
                        }).map({ (value: String?) -> String in
                            return value!
                        })
                        
                        datas.append(contentsOf: textList)
                    }
                    
                    if datas.isEmpty == false {
                        let tableRow = DataTableRow(header: strongThText, datas: datas)
                        officeDataTable.addRow(row: tableRow)
                    }
                } //for rowNode
                
                var mapUrl: URL?
                let mapRefNode = try body?.select("#menu-map li a").last()
                if let mapRef = mapRefNode {
                    let rawUrl = try mapRef.attr("href")
                    mapUrl = URL(string: rawUrl, relativeTo: url)
                }
                
                return BankDetailResult(dataTables: officeDataTables, mapUrl: mapUrl)
            }
        
        return BankDetailResult()
    }
    
    private func isNamelessOffice(inputStr: String) -> Bool {
        let pattern = "^\\d+\\.$"
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let str = inputStr as NSString
            let res = regex.matches(in: inputStr, options: [], range: NSRange(location: 0, length: str.length))

            return res.count > 0
        }
        
        return false
    }
    
    func getOfficeGeoDatas(html: String) throws -> [OfficeGeoData] {
        let sourceArray = getGeoSource(html: html)
        if sourceArray.isEmpty {
            return []
        }
        
        guard let jsonSource = sourceArray[safe:0] else {throw SiteParserError.parsingError()}
        let json = "{\"values\":[[\(jsonSource)]]}"
        let data = try parseGeoData(json: json)
        
        return try data.values.map{
            guard let num = $0[safe:0] as? Int else {throw SiteParserError.parsingError()}
            guard let officeName = $0[safe:2] as? String else {throw SiteParserError.parsingError()}
            guard let address = $0[safe:3] as? String else {throw SiteParserError.parsingError()}
            guard let geoArray = $0[safe:1] as? [Double] else {throw SiteParserError.parsingError()}
            guard let bankName = $0[safe:7] as? String else {throw SiteParserError.parsingError()}
                            
            return OfficeGeoData(num: num, officeName: officeName, bankName: bankName, latitude: geoArray[0], longitude: geoArray[1], address: address)
        }
    }
    
    private func getGeoSource(html: String) -> [String] {
        let pattern = "var brarr = \\[\\[(.*)\\]\\],"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [ .dotMatchesLineSeparators ]) {
            let str = html as NSString
            return regex.matches(in: html, options: [], range: NSRange(location: 0, length: str.length)).map {
                //str.substring(with: $0.range)
                fixJsonQuotes(json: str.substring(with: $0.range(at: 1)))
            }
        }
        
        return []
    }
    
    private func fixJsonQuotes(json: String) -> String {
        var resStr: String = ""
        for s in json {
            if s == "\"" {
                resStr.append("'")
            }
            else if s == "'" {
                resStr.append("\"")
            }
            else {
                resStr.append(s)
            }
        }
        return resStr
    }
    
    private func parseGeoData(json: String) throws -> ParsedGeoData {
        let jsonData = json.data(using: .utf8)!
        let result = try JSONDecoder().decode(ParsedGeoData.self, from: jsonData)
        return result
    }
    
    private func parseSubtable(tableElement: Element) throws -> [String]  {
        let trNodes = try tableElement.select("tr")
        var datas: [String] = []
        
        for rowNode in trNodes {
            let tdNodes = try rowNode.select("td")
            
            var strData = ""
            for tdNode in tdNodes {
                let text = try? tdNode.text()
                if text == nil || text!.isEmpty {
                    continue
                }
                
                strData += (" " + text!)
                strData = strData.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if strData.isEmpty == false {
                datas.append(strData)
            }
        }
        
        return datas
    }
    
    func getCities(html: String) throws -> [City] {
        let doc: Document = try SwiftSoup.parseBodyFragment(html)
        guard let body = doc.body() else { throw SiteParserError.parsingError()}
        
        let cityTables = try body.select("#maket .cities")
        if cityTables.count < 2 {
            throw SiteParserError.parsingError("cityTables is not found")
        }
        
        guard let cityTable = cityTables[safe:1] else {throw SiteParserError.parsingError()}
        let links = try cityTable.select("table tr td a")
        
        return links.map {
            var href = try? $0.attr("href").trimmingCharacters(in: .whitespacesAndNewlines)
            let text = try? $0.text().trimmingCharacters(in: .whitespacesAndNewlines)
            
            let isDefault = text?.caseInsensitiveCompare("Москва") == .orderedSame
            if isDefault {
                href = Constants.defaultCityId
            }
            
            if let hrefValue = href, let textValue = text {
                return City(name: textValue, url: hrefValue, isDefault: isDefault)
            }
            return nil
        }
        .filter{
            $0 != nil
        }
        .map{
            // this is safe
            $0!
        }
    }
    
    func getExchanges(html: String) throws -> ExchangeListResult {
        var exchanges: [CurrencyExchange] = []
        var cbInfo = CentralBankInfo()
        
        let doc: Document = try SwiftSoup.parseBodyFragment(html)
        let body = doc.body()
        guard let strongBody = body else {throw SiteParserError.parsingError("body wrong")}
        
        // .cb-title table tr
        let trElements = try strongBody.select(".cb-title table tr")
        guard let tr2 = trElements[safe:2] else { throw SiteParserError.parsingError() }
        let tr2TdElements = try tr2.select("td")
        guard var usdRateStr = try tr2TdElements[safe:1]?.text() else { throw SiteParserError.parsingError() }
        
        guard let tr3 = trElements[safe:3] else {throw SiteParserError.parsingError()}
        let tr3TdElements = try tr3.select("td")
        guard var euroRateStr = try tr3TdElements[safe:1]?.text() else { throw SiteParserError.parsingError()}
        
        usdRateStr = replaceDecimalDot(decimalStr: usdRateStr)
        euroRateStr = replaceDecimalDot(decimalStr: euroRateStr)
        
        let formatter = getDecimalFormatter()
        if let number = formatter.number(from: usdRateStr) {
            let value = number.decimalValue
            cbInfo.usdExchangeRate.rate = value
            cbInfo.usdExchangeRate.rateStr = usdRateStr
        }
        if let number = formatter.number(from: euroRateStr) {
            let value = number.decimalValue
            cbInfo.euroExchangeRate.rate = value
            cbInfo.euroExchangeRate.rateStr = euroRateStr
        }
        
        // .plain-content table.tb-k
        let table = try strongBody.select(".plain-content table.tb-k").first()
        
        guard let strongTable = table else {throw SiteParserError.parsingError("table")}
        let tableRows = try strongTable.select("tr.wigr1,tr.wi")
        
        for row in tableRows {
            if row.hasClass("bot") == false {
                if row.hasClass("wi") {
                    let text = try row.select("td.old").text()
                    if text.starts(with: "Лучшие курсы") {
                        continue
                    }
                }
                
                var exchange = CurrencyExchange()
                let tdBank = try row.select("td.tbn").first()
                if let theTdBank = tdBank {
                    let bankRef = try theTdBank.select("a").first()
                    
                    if let theBankRef = bankRef {
                        exchange.bankName = try theBankRef.text()
                        exchange.bankUrl = try theBankRef.attr("href")
                    }
                    else {
                        exchange.bankName = try theTdBank.text()
                    }
                }
                
                let bankRef = try row.select("td.tbn a").first()
                if let theBankRef = bankRef {
                    exchange.bankName = try theBankRef.text()
                    exchange.bankUrl = try theBankRef.attr("href")
                }
                
                let timeData = try row.select("td.upd-t").first()
                if let theTimeData = timeData {
                    exchange.updatedTime = theTimeData.ownText()
                }
                
                let tdatas = try row.select("td")
                let formatter = getDecimalFormatter()
                
                guard let tdata1 = tdatas[safe:1] else {throw SiteParserError.parsingError()}
                guard let tdata2 = tdatas[safe:2] else {throw SiteParserError.parsingError()}
                guard let tdata3 = tdatas[safe:3] else {throw SiteParserError.parsingError()}
                guard let tdata4 = tdatas[safe:4] else {throw SiteParserError.parsingError()}
                
                exchange.usdExchange = try getCurrencyExchangeUnit(currBuyElement: tdata1, currSellElement: tdata2, formatter: formatter)
                
                exchange.euroExchange = try getCurrencyExchangeUnit(currBuyElement: tdata3, currSellElement: tdata4, formatter: formatter)
                
                exchanges.append(exchange)
            }
        }
        
        return ExchangeListResult(exchanges: exchanges, cbInfo: cbInfo)
    }
    
    private func replaceDecimalDot(decimalStr: String) -> String {
        decimalStr.replacingOccurrences(of: ".", with: ",")
    }
    
    private func getDecimalFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }
    
    private func getCurrencyExchangeUnit(currBuyElement: Element, currSellElement: Element, formatter: NumberFormatter) throws -> CurrencyExchangeUnit {
        var exchange = CurrencyExchangeUnit()
        
        let strCurrBuy = try currBuyElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
        let isBestBuy1 = currBuyElement.hasClass("b-k")
        
        if let number = formatter.number(from: strCurrBuy) {
            let value = number.decimalValue
            exchange.amountBuy = value
            exchange.strAmountBuy = strCurrBuy
            exchange.isBestBuy = isBestBuy1
        }
        
        let strCurrSell = try currSellElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
        let isBestBuy2 = currSellElement.hasClass("b-k")
        
        if let number = formatter.number(from: strCurrSell) {
            let value = number.decimalValue
            exchange.amountSell = value
            exchange.strAmountSell = strCurrSell
            exchange.isBestSell = isBestBuy2
        }
        
        return exchange
    }
    
}


