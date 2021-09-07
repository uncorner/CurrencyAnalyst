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
    // урл у банка может быть и пустой
    var bankUrl = ""
    var bankLogoUrl: String?
    var updatedTime = ""
    var usdExchange = CurrencyExchangeUnit()
    var euroExchange = CurrencyExchangeUnit()
    
    var fullBankUrl: String {
        if bankUrl.starts(with: "https:") {
            return bankUrl
        }
        
        // temp
        if bankUrl.isEmpty {
            return ""
        }
        
        let url = URL(string: bankUrl, relativeTo: URL(string: "https://kovalut.ru/") )!
        return url.absoluteString
    }

}
