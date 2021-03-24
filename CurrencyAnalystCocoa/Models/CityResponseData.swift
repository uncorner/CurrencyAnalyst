//
//  CityResponseData.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 23.03.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation

struct CityResponseData {
    let cities: [City]?
    let exchangeListResult: ExchangeListResult?
    let response: HTTPURLResponse
    
}
