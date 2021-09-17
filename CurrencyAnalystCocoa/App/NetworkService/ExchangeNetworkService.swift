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
        return doRequestData(url: Constants.Urls.citiesUrl.toSiteURL()!)
            .map { response, data -> [City]? in
                let html = String(decoding: data, as: UTF8.self)
                return try self.dataSource.getCities(html: html)
            }
            .asSingle()
    }
    
    func getExchangesSeq(exchangeUrl url: URL) -> Single<ExchangeListResult> {
        return doRequestData(url: url)
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
    
    func getBankDetailSeq(url: URL) -> Single<BankDetailResult> {
        return doRequestData(url: url)
            .map { response, data -> BankDetailResult in
                let html = String(decoding: data, as: UTF8.self)
                return try self.dataSource.getBankDetail(html: html, url: url)
            }
            .asSingle()
    }
    
    func getOfficeGeoDatasSeq(url: URL) -> Single<[OfficeGeoData]> {
        return doRequestData(url: url)
            .map { response, data -> [OfficeGeoData] in
                let html = String(decoding: data, as: UTF8.self)
                return try self.dataSource.getOfficeGeoDatas(html: html)
            }
            .asSingle()
    }
    
    // MARK: private methods
    private func doRequestData(url: URL) -> Observable<(HTTPURLResponse, Data)> {
        return RxAlamofire.request(.get, url)
            .validate()
            .responseData()
    }
    
}
