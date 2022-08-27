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
import Action
import CoreData

final class ExchangeListViewModel {
    
    private static let sectionedItemsEmptyData = [
        ExchangeTableViewSection(items: []),
        ExchangeTableViewSection(items: [])
    ]
    
    private let sceneCoordinator: MvvmSceneCoordinator
    private let disposeBag = DisposeBag()
    private let networkService: NetworkService
    private let storageRepository: StorageRepository
    private let prvExchangeItems = BehaviorRelay(value: sectionedItemsEmptyData)
    private let prvLoadingStatus = BehaviorRelay<DataLoadingStatus>(value: .none)
    private let prvCbDollarRate = PublishRelay<String>()
    private let prvCbEuroRate = PublishRelay<String>()
    private var prvCities = [City]()
    private var exchangeListResult = ExchangeListResult()
    private var isFirstDataLoading = true
    
    // MARK: In
    var selectedCityId = Constants.defaultCityId
    
    // MARK: Out
    var isNeedAutoUpdate = true
    
    var exchangeItems: Driver<[ExchangeTableViewSection]> {
        prvExchangeItems.asDriver()
    }
    var loadingStatus: Driver<DataLoadingStatus> {
        prvLoadingStatus.asDriver()
    }
    var cbDollarRate: Driver<String> {
        prvCbDollarRate.asDriver(onErrorJustReturn: Constants.rateStub)
    }
    var cbEuroRate: Driver<String> {
        prvCbEuroRate.asDriver(onErrorJustReturn: Constants.rateStub)
    }
    var cities: [City] {
        prvCities
    }
    
    // MARK: Actions
    lazy var onLoadCitiesAndExchanges = CocoaAction(workFactory: loadCitiesAndExchanges)
    lazy var onShowPickCity = CocoaAction(workFactory: showPickCity)
    
    init(sceneCoordinator: MvvmSceneCoordinator, networkService: NetworkService, storageRepository: StorageRepository) {
        self.sceneCoordinator = sceneCoordinator
        self.networkService = networkService
        self.storageRepository = storageRepository
    }
    
    private func showPickCity() -> Observable<Void> {
        let callback: (String)->() = { [weak self] cityId in
            guard let self = self else {return}
            self.isNeedAutoUpdate = self.selectedCityId != cityId
            if self.isNeedAutoUpdate {
                self.selectedCityId = cityId
                let userDefaults = UserDefaults.standard
                userDefaults.setCityId(cityId: cityId)
            }
        }
        
        let viewModel = PickCityViewModel(sceneCoordinator: sceneCoordinator, cities: cities, setSelectedCityIdCallback: callback,selectedCityId: selectedCityId)
        sceneCoordinator.transition(to: MvvmScene.pickCityViewModel(viewModel), type: .push)
        return .empty()
    }
    
    func showDetailBank(exchange: CurrencyExchange) {
        let viewModel = DetailBankViewModel(sceneCoordinator: sceneCoordinator, networkService: networkService, exchange: exchange)
        sceneCoordinator.transition(to: MvvmScene.detailBankViewModel(viewModel), type: .push)
    }
    
    func loadAppSettings() {
        let userDefaults = UserDefaults.standard
        selectedCityId = userDefaults.getCityId() ?? Constants.defaultCityId
    }
    
    func saveLastExchangeData() {
        if !exchangeListResult.exchanges.isEmpty {
            storageRepository.saveExchangeListResult(listResult: exchangeListResult)
        }
    }
    
    private func fetchExchangeListResult() -> Observable<ExchangeListResult> {
        Observable.just(self.storageRepository.fetchExchangeListResult())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    private func acceptExchangeList(_ self: ExchangeListViewModel, _ exchangeListResult: ExchangeListResult) {
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
    }
    
    private func loadCitiesAndExchanges() -> Observable<Void> {
        print(#function)
        guard let exchangeUrl = selectedCityId.toSiteURL() else {return .empty()}
        print("loadExchanges url: \(exchangeUrl.absoluteString); selected city id: \(selectedCityId)")
        
        prvLoadingStatus.accept(.loading)
        var citiesSeq: Single<[City]?> = Single.just(nil)
        if prvCities.isEmpty {
            citiesSeq = networkService.getCitiesSeq()
        }
        
        let exchangesSeq = networkService.getExchangesSeq(exchangeUrl: exchangeUrl)
        // комбинируем две последовательности: города и курсы валют, запросы будут выполняться параллельно
        let citiesAndExchangesSeq = Single.zip(citiesSeq, exchangesSeq).asObservable()
        var resultSeq = citiesAndExchangesSeq
        
        if isFirstDataLoading {
            let cachedSeq = fetchExchangeListResult()
                .map { (exchangeListResult) -> ([City]?, ExchangeListResult) in
                    return (nil, exchangeListResult)
                }
                .catchAndReturn((nil, ExchangeListResult()))
            
            resultSeq = cachedSeq.concat(citiesAndExchangesSeq)
            print("cached data will be used")
        }
        
        resultSeq.observe(on: MainScheduler.instance)
            .subscribe { [weak self] (cities, exchangeListResult) in
                guard let self = self else {return}
                DispatchQueue.printCurrentQueue()
                
                if let cities = cities {
                    print("cities loaded")
                    self.prvCities = cities
                }
                self.exchangeListResult = exchangeListResult
                self.prvCbDollarRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.usdExchangeRate))
                self.prvCbEuroRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.euroExchangeRate))
                self.acceptExchangeList(self, exchangeListResult)
                print("exchange list loaded")
            } onError: { [weak self] error in
                print("onError")
                self?.prvLoadingStatus.accept(.fail(error: error))
            } onCompleted: { [weak self] in
                print("onCompleted")
                self?.prvLoadingStatus.accept(.success)
            } onDisposed: { [weak self] in
                print("onDisposed")
                self?.isFirstDataLoading = false
            }
            .disposed(by: disposeBag)
        
        return .empty()
    }
    
    private func getCbExchangeRateAsText(_ exchangeRate: CbCurrencyExchangeRate) -> String {
        if exchangeRate.rate == 0 {
            return Constants.rateStub
        }
        return exchangeRate.rateStr
    }
    
}
