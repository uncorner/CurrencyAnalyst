//
//  ExchangeDataSourceFactory.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 26.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

final class ExchangeDataSourceFactory {
    
    static func create() -> ExchangeDataSource {
        return SiteParser()
    }
    
}
