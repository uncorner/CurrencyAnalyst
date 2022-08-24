//
//  DecimalExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 23.08.2022.
//  Copyright © 2022 uncorner. All rights reserved.
//

import Foundation

extension Decimal {
    var formattedAmount: String? {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.currencySymbol = ""
        formatter.currencyCode = ""
        formatter.currencyGroupingSeparator = ""
        formatter.currencyDecimalSeparator = "."
        
        return formatter.string(from: self as NSDecimalNumber)
    }
}

