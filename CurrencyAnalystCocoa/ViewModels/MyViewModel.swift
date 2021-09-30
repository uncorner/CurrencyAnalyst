//
//  MainViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 21.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class MyViewModel {
    
    private static let sectionedItemsEmptyData = [
        ExchangeTableViewSection(items: []),
        ExchangeTableViewSection(items: [])
    ]
    
    private let disposeBag = DisposeBag()
    private let networkService: NetworkService
    
    private let prvExchangeItems = BehaviorRelay(value: sectionedItemsEmptyData)
    private let prvLoadingStatus = BehaviorRelay<DataLoadingStatus>(value: .none)
    private let prvCbDollarRate = PublishRelay<String>()
    private let prvCbEuroRate = PublishRelay<String>()
    private var prvCities = [City]()
    
    // MARK: IN
    var selectedCityId = Constants.defaultCityId
    
    // MARK: OUT
    var exchangeItems: Driver<[ExchangeTableViewSection]> {
        prvExchangeItems.asDriver()
    }
    var loadingStatus: Driver<DataLoadingStatus> {
        prvLoadingStatus.asDriver()
    }
    var cbDollarRate: Driver<String> {
        prvCbDollarRate.asDriver(onErrorJustReturn: Constants.cbRateStub)
    }
    var cbEuroRate: Driver<String> {
        prvCbEuroRate.asDriver(onErrorJustReturn: Constants.cbRateStub)
    }
    var cities: [City] {
        prvCities
    }
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func loadAppSettings() {
        let userDefaults = UserDefaults.standard
        selectedCityId = userDefaults.getCityId() ?? Constants.defaultCityId
    }
    
    func loadCitiesAndExchanges() {
        print(#function)
        guard let exchangeUrl = selectedCityId.toSiteURL() else {return}
        print("loadExchanges url: \(exchangeUrl.absoluteString); selected city id: \(selectedCityId)")
        
        prvLoadingStatus.accept(.loading)
        var citiesSeq: Single<[City]?> = Single.just(nil)
        if prvCities.isEmpty {
            citiesSeq = networkService.getCitiesSeq()
        }
        let exchangesSeq = networkService.getExchangesSeq(exchangeUrl: exchangeUrl)
        
        // комбинируем две последовательности: города и курсы валют, запросы будут выполняться параллельно
        Single.zip(citiesSeq, exchangesSeq)
            .subscribe { [weak self] cities, exchangeListResult in
                guard let self = self else {return}
                DispatchQueue.printCurrentQueue()
                
                if let cities = cities {
                    print("cities loaded")
                    self.prvCities = cities
                }
                
                self.prvCbDollarRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.usdExchangeRate))
                self.prvCbEuroRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.euroExchangeRate))
                
                let items = exchangeListResult.exchanges.map { exchange in
                    ExchangeTableViewItem.ExchangeItem(exchange: exchange)
                }
                
                let city = self.prvCities.first(where: {
                    $0.id == self.selectedCityId
                })
                let cityName = city?.name ?? ""
                let headItem = ExchangeTableViewItem.HeadItem(cityName: cityName)
                
                let sectionsWithData = [
                    ExchangeTableViewSection(items: [headItem]),
                    ExchangeTableViewSection(items: items)]
                
                self.prvExchangeItems.accept(sectionsWithData)
                print("exchange list loaded")
            } onFailure: { [weak self] (error) in
                self?.prvLoadingStatus.accept(.fail(error: error))
            } onDisposed: { [weak self] in
                print("onDisposed")
                self?.prvLoadingStatus.accept(.success)
            }
            .disposed(by: disposeBag)
    }
    
    private func getCbExchangeRateAsText(_ exchangeRate: CbCurrencyExchangeRate) -> String {
        if exchangeRate.rate == 0 {
            return Constants.cbRateStub
        }
        return exchangeRate.rateStr
    }
    
}
