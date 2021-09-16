//
//  NetworkService.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 16.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxSwift

protocol NetworkService {
    
    init(dataSource: ExchangeDataSource)
    
    func getCitiesSeq() -> Single<[City]?>
    
    func getExchangesSeq(exchangeUrl: URL) -> Single<ExchangeListResult>
    
}
