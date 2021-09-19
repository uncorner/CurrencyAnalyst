//
//  NetworkServiceFactory.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 16.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation

final class NetworkServiceFactory {
    
    static func create(dataSource: ExchangeDataSource) -> NetworkService {
        return ExchangeNetworkService(dataSource: dataSource);
    }
    
}
