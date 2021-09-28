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
    
    private static let sectionsEmptyData = [
        ExchangeTableViewSection(items: []),
        ExchangeTableViewSection(items: [])
    ]
    
    private let disposeBag = DisposeBag()
    

    // OUT
    let sectionedItemsSeq = BehaviorSubject(value: sectionsEmptyData)
    let isMainActivityAnimatingAndLock = BehaviorSubject(value: true)
    //let isTableViewActivityAnimating = BehaviorSubject(value: false)
    let tableViewActivityAnimating = PublishSubject<Void?>()
    
    
    var exchangeListResult = ExchangeListResult()
    var cities = [City]()
    var selectedCityId = Constants.defaultCityId
    var isNeedUpdate = true
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
   
    func loadCitiesAndExchanges(isShownMainActivity: Bool) {
        print(#function)
        guard let exchangeUrl = selectedCityId.toSiteURL() else {return}
        print("loadExchanges url: \(exchangeUrl.absoluteString); selected city id: \(selectedCityId)")
        
        //startActivityAnimatingAndLock(isActivityAnimating: isShownMainActivity)
        //isMainActivityAnimatingAndLock.onNext(isShownMainActivity)
        
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
                
                //>>>>>>>>>>>
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
                
                self.sectionedItemsSeq.onNext(sectionsWithData)
                
                print("exchange list loaded")
                
            } onFailure: { [weak self] (error) in
                //self?.processResponseError(error)
                self?.isMainActivityAnimatingAndLock.onNext(false)
                //self?.isTableViewActivityAnimating.onNext(false)
                self?.tableViewActivityAnimating.onNext(nil)
                
            } onDisposed: { [weak self] in
                print("onDisposed")
                //self?.stopAllActivityAnimatingAndUnlock()
                self?.isMainActivityAnimatingAndLock.onNext(false)
                //self?.isTableViewActivityAnimating.onNext(false)
                self?.tableViewActivityAnimating.onNext(nil)
                
            }
            .disposed(by: disposeBag)
    }
    
}
