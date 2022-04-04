//
//  CurrencyExchangeUnit.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 28.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

struct CurrencyExchangeUnit {
    
    var amountBuy: Decimal = 0
    var amountSell: Decimal = 0
    var strAmountBuy = Constants.rateStub
    var strAmountSell = Constants.rateStub
    
    var isBestBuy = false
    var isBestSell = false
        
}
