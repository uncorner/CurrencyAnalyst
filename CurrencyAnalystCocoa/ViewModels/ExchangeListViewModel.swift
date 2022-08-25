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
    
    private var isDataLoaded: Bool {
        !prvCities.isEmpty && !exchangeListResult.exchanges.isEmpty
    }
    
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
    
//    private func loadFromCache() -> Observable<Void> {
//        print(#function)
//        guard let exchangeUrl = selectedCityId.toSiteURL() else {return .empty()}
//        print("loadExchanges url: \(exchangeUrl.absoluteString); selected city id: \(selectedCityId)")
//
//        prvLoadingStatus.accept(.loading)
//        var citiesSeq: Single<[City]?> = Single.just(nil)
//        if prvCities.isEmpty {
//            citiesSeq = networkService.getCitiesSeq()
//        }
//
//        //let exchangesSeq = networkService.getExchangesSeq(exchangeUrl: exchangeUrl)
//        //>>>>>>>>>>
//        let datas = self.storageRepository.fetchData()
//        let exchangesSeq = Single.just(datas)
//
//        // комбинируем две последовательности: города и курсы валют, запросы будут выполняться параллельно
//        Single.zip(citiesSeq, exchangesSeq)
//            .subscribe { [weak self] cities, exchangeListResult in
//                guard let self = self else {return}
//                DispatchQueue.printCurrentQueue()
//
//                if let cities = cities {
//                    print("cities loaded")
//                    self.prvCities = cities
//                }
//
//                self.exchangeListResult = exchangeListResult
//
//                self.prvCbDollarRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.usdExchangeRate))
//                self.prvCbEuroRate.accept(self.getCbExchangeRateAsText( exchangeListResult.cbInfo.euroExchangeRate))
//
//                let items = exchangeListResult.exchanges.map { exchange in
//                    ExchangeTableViewItem.ExchangeItem(exchange: exchange)
//                }
//
//                let city = self.prvCities.first(where: {
//                    $0.id == self.selectedCityId
//                })
//                let cityName = city?.name ?? ""
//                let headItem = ExchangeTableViewItem.HeadItem(cityName: cityName)
//
//                let sectionsWithData = [
//                    ExchangeTableViewSection(items: [headItem]),
//                    ExchangeTableViewSection(items: items)]
//
//                self.prvExchangeItems.accept(sectionsWithData)
//                print("exchange list loaded")
//            } onFailure: { [weak self] (error) in
//                self?.prvLoadingStatus.accept(.fail(error: error))
//            } onDisposed: { [weak self] in
//                print("onDisposed")
//                self?.prvLoadingStatus.accept(.success)
//            }
//            .disposed(by: disposeBag)
//
//        return .empty()
//    }
    
    
    private func acceptExchangeList(_ self: ExchangeListViewModel, _ exchangeListResult: ExchangeListResult) {
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
    }
    
    // вызывать два метода preload и потом loadCitiesAndExchanges в viewDidLoad of ViewController
    private func loadCitiesAndExchanges() -> Observable<Void> {
        print(#function)
        guard let exchangeUrl = selectedCityId.toSiteURL() else {return .empty()}
        print("loadExchanges url: \(exchangeUrl.absoluteString); selected city id: \(selectedCityId)")
        
        prvLoadingStatus.accept(.loading)
        var citiesSeq: Single<[City]?> = Single.just(nil)
        if prvCities.isEmpty {
            citiesSeq = networkService.getCitiesSeq()
        }
        
        //>>>>>>>>>>
        /*
        let cachedExchangeList = self.storageRepository.fetchData()
        //let exchangesSeq = Single.just(datas)
        self.acceptExchangeList(self, cachedExchangeList)
        print("exchange list loaded from cache")
        */
        
        //let cachedExchangeList = self.storageRepository.fetchData()
        
        let exchangesSeq = networkService.getExchangesSeq(exchangeUrl: exchangeUrl)
        // комбинируем две последовательности: города и курсы валют, запросы будут выполняться параллельно
        let networkSeq = Single.zip(citiesSeq, exchangesSeq).asObservable()
        var resultSeq = networkSeq
        
        if !isDataLoaded {
            let cachedSeq = Observable.just(self.storageRepository.fetchData()).map { exchangeListResult  in
                return (nil as ([City]?), exchangeListResult)
            }.catchAndReturn((nil, ExchangeListResult())) //<<<<<<<<<
            
            resultSeq = cachedSeq.concat(networkSeq)
            print("cached data will be used")
        }
        
        resultSeq.subscribe { [weak self] (cities, exchangeListResult) in
            guard let self = self else {return}
            DispatchQueue.printCurrentQueue()
            
            if let cities = cities {
                print("cities loaded")
                self.prvCities = cities
            }
            
            self.exchangeListResult = exchangeListResult
            self.acceptExchangeList(self, exchangeListResult)
            print("exchange list loaded")
        } onError: { [weak self] error in
            self?.prvLoadingStatus.accept(.fail(error: error))
        } onCompleted: {
            // todo: del this section
            print("onCompleted")
        } onDisposed: { [weak self] in
            print("onDisposed")
            self?.prvLoadingStatus.accept(.success)
        }
        .disposed(by: disposeBag)
        
        
//            .subscribe { [weak self] cities, exchangeListResult in
//                guard let self = self else {return}
//                DispatchQueue.printCurrentQueue()
//
//                if let cities = cities {
//                    print("cities loaded")
//                    self.prvCities = cities
//                }
//
//                self.exchangeListResult = exchangeListResult
//                self.acceptExchangeList(self, exchangeListResult)
//                print("exchange list loaded")
//            }
//
//            } onFailure: { [weak self] (error) in
//                self?.prvLoadingStatus.accept(.fail(error: error))
//            }
            
//    onDisposed: { [weak self] in
//                print("onDisposed")
//                self?.prvLoadingStatus.accept(.success)
//            }
//            .disposed(by: disposeBag)
        
        return .empty()
    }
    
    private func getCbExchangeRateAsText(_ exchangeRate: CbCurrencyExchangeRate) -> String {
        if exchangeRate.rate == 0 {
            return Constants.rateStub
        }
        return exchangeRate.rateStr
    }
    
}
