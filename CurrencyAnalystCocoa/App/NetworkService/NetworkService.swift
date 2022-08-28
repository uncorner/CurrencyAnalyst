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
    
    func getCities() -> Single<[City]?>
    
    func getExchanges(exchangeUrl: URL) -> Single<ExchangeListResult>
    
    func getBankDetail(url: URL) -> Single<BankDetailResult>
    
    func getOfficeGeoDatas(url: URL) -> Single<[OfficeGeoData]>
    
    func getImage(url: URL) -> Single<UIImage?>
    
}
