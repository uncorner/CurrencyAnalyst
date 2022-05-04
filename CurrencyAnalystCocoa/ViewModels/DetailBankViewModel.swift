//
//  DetailBankViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 01.11.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class DetailBankViewModel {
    private let sceneCoordinator: MvvmSceneCoordinator
    private let disposeBag = DisposeBag()
    private var networkService: NetworkService
    private let loadingStatus = BehaviorRelay<DataLoadingStatus>(value: .none)
    
    // MARK: Out
    let exchangeSeq: BehaviorRelay<CurrencyExchange>
    var mapUrl: URL?
    let bankOfficeItems = BehaviorRelay<[BankOfficeTableViewSection]>(value: [])
    
    var bankOfficeItemsValue: [BankOfficeTableViewSection] {
        bankOfficeItems.value
    }
    
    init(sceneCoordinator: MvvmSceneCoordinator, networkService: NetworkService, exchange: CurrencyExchange) {
        self.sceneCoordinator = sceneCoordinator
        self.networkService = networkService
        self.exchangeSeq = BehaviorRelay<CurrencyExchange>(value: exchange)
    }
    
    func loadBankOfficeData() {
        print(#function)
        guard let url = exchangeSeq.value.bankUrl?.toSiteURL() else {return}
        //startActivityAnimatingAndLock()
        loadingStatus.accept(.loading)
        
        networkService.getBankDetailSeq(url: url).subscribe { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.printCurrentQueue()
            
            let sections: [BankOfficeTableViewSection] =  result.dataTables.map({
                let item1 = BankOfficeTableViewItemData(officeDataTable: $0)
                let item2 = BankOfficeTableViewItemHeader(text: $0.header)
                return BankOfficeTableViewSection(officeItems: [item2, item1])
            })
            
            self.mapUrl = result.mapUrl
            
            //>>> TODO
//            self.shouldBeDisplayedOfficeTableBoxView = true
//            if UIWindow.isLandscape == false {
//                // portrait mode
//                self.showOfficeTableBoxView()
//            }
            
            self.bankOfficeItems.accept(sections)
            
            print("bank details loaded")
        } onFailure: { [weak self] error in
            //self?.processResponseError(error)
            self?.loadingStatus.accept(.fail(error: error))
        } onDisposed: { [weak self] in
            //self?.stopActivityAnimatingAndUnlock()
            print("onDisposed")
            self?.loadingStatus.accept(.success)
        }
        .disposed(by: disposeBag)
    }
    
}


