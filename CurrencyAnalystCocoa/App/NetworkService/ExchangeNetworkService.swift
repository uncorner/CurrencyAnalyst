//
//  ExchangeNetworkService.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 16.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

class ExchangeNetworkService: NetworkService {
    private let dataSource: ExchangeDataSource
    
    required init(dataSource: ExchangeDataSource) {
        self.dataSource = dataSource
    }
    
    func getCitiesSeq() -> Single<[City]?> {
        return RxAlamofire.request(.get, Constants.Urls.citiesUrl)
            .validate()
            .responseData()
            .map { response, data -> [City]? in
                let html = String(decoding: data, as: UTF8.self)
                return try self.dataSource.getCities(html: html)
            }
            .asSingle()
    }
    
    func getExchangesSeq(exchangeUrl: URL) -> Single<ExchangeListResult> {
        return RxAlamofire.request(.get, exchangeUrl)
            .validate()
            .responseData()
            .map { response, data -> ExchangeListResult in
                let html = String(decoding: data, as: UTF8.self)
                do {
                    return try self.dataSource.getExchanges(html: html)
                } catch {
                    print("Error getExchanges(): \(error.localizedDescription)")
                    return ExchangeListResult()
                }
            }
            .asSingle()
    }
    
}
