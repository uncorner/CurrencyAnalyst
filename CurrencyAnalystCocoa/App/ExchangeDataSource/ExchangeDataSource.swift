//
//  ExchangeDataSource.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 26.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

protocol ExchangeDataSource {
    
    func getBankDetail(html: String, url: URL) throws -> BankDetailResult
    
    func getOfficeGeoDatas(html: String) throws -> [OfficeGeoData]
    
    func getCities(html: String) throws -> [City]
    
    func getExchanges(html: String) throws -> ExchangeListResult
    
}
