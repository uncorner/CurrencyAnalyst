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

enum DataLoadingStatus {
    case none
    case loading
    case success
    case fail(error: Error)
}

final class MyViewModel {
    
    private static let sectionsEmptyData = [
        ExchangeTableViewSection(items: []),
        ExchangeTableViewSection(items: [])
    ]
    
    private let disposeBag = DisposeBag()
    private let networkService: NetworkService

    // OUT
    let exchangeItems = BehaviorRelay(value: sectionsEmptyData)
    //let isMainActivityAnimatingAndLock = BehaviorSubject(value: true)
    //let tableViewActivityAnimating = PublishSubject<Void?>()
    let loadingStatus = BehaviorRelay<DataLoadingStatus>(value: .none)
    let cbDollarRate = PublishRelay<String>()
    let cbEuroRate = PublishRelay<String>()
        
    var exchangeListResult = ExchangeListResult()
    var cities = [City]()
    //var isNeedUpdate = true
    
    // IN
    var selectedCityId = Constants.defaultCityId
    
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
        
        //startActivityAnimatingAndLock(isActivityAnimating: isShownMainActivity)
        //isMainActivityAnimatingAndLock.onNext(isShownMainActivity)
        loadingStatus.accept(.loading)
        
        var citiesSeq: Single<[City]?> = Single.just(nil)
        if cities.isEmpty {
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
                    self.cities = cities
                }
                self.exchangeListResult = exchangeListResult
                
//                self.cbDollarRateLabel.text = self.getCbExchangeRateAsText( self.exchangeListResult.cbInfo.usdExchangeRate )
//                self.cbEuroRateLabel.text = self.getCbExchangeRateAsText( self.exchangeListResult.cbInfo.euroExchangeRate )
//                self.cbBoxView.isHidden = false
//                // update table
//                self.isNeedUpdate = false
//                self.tableView.reloadData()
//                // scroll table on top
//                if self.tableView.numberOfRows(inSection: 0) > 0 {
//                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
//                }
                
                self.cbDollarRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.usdExchangeRate))
                self.cbEuroRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.euroExchangeRate))
                                
                let items = exchangeListResult.exchanges.map { exchange in
                    ExchangeTableViewItem.ExchangeItem(exchange: exchange)
                }
                
                let city = self.cities.first(where: {
                    $0.id == self.selectedCityId
                })
                let cityName = city?.name ?? ""
                let headItem = ExchangeTableViewItem.HeadItem(cityName: cityName)
                
                let sectionsWithData = [
                    ExchangeTableViewSection(items: [headItem]),
                    ExchangeTableViewSection(items: items)]
                
                self.exchangeItems.accept(sectionsWithData)
                
                print("exchange list loaded")
                
            } onFailure: { [weak self] (error) in
                //self?.processResponseError(error)
                //self?.isMainActivityAnimatingAndLock.onNext(false)
                //self?.isTableViewActivityAnimating.onNext(false)
                //self?.tableViewActivityAnimating.onNext(nil)
                self?.loadingStatus.accept(.fail(error: error))
                
            } onDisposed: { [weak self] in
                print("onDisposed")
                //self?.stopAllActivityAnimatingAndUnlock()
                //self?.isMainActivityAnimatingAndLock.onNext(false)
                //self?.isTableViewActivityAnimating.onNext(false)
                //self?.tableViewActivityAnimating.onNext(nil)
                self?.loadingStatus.accept(.success)
                
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
