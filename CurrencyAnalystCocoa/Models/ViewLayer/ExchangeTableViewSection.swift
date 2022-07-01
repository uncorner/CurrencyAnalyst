//
//  ExchangeTableViewSection.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 23.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxDataSources

enum ExchangeTableViewItem {
    case ExchangeItem(exchange: CurrencyExchange)
    case HeadItem(cityName: String)
}

struct ExchangeTableViewSection {
  //var header: String
  var items: [Item]
}

extension ExchangeTableViewSection: SectionModelType {
    typealias Item = ExchangeTableViewItem
    
    init(original: Self, items: [ExchangeTableViewItem]) {
        self = original
        self.items = items
    }
    
}
