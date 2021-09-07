//
//  CurrencyExchange.swift
//  CurrencyAnalyst
//
//  Created by denis on 19.03.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

struct CurrencyExchange {
    var bankName = ""
    var bankUrl: String?
    var bankLogoUrl: String?
    var updatedTime = ""
    var usdExchange = CurrencyExchangeUnit()
    var euroExchange = CurrencyExchangeUnit()
    
}
