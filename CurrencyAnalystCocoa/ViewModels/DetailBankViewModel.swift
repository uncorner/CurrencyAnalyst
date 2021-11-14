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
    
    //private
    let prvBankOfficeItems = BehaviorRelay<[BankOfficeTableViewSection]>(value: [])
    private let prvLoadingStatus = BehaviorRelay<DataLoadingStatus>(value: .none)
    private let exchange: CurrencyExchange
    
    // MARK: Out
    var mapUrl: URL?
//    var bankOfficeItems: Driver<[BankOfficeTableViewSection]> {
//        prvBankOfficeItems.asDriver()
//    }
    
    var bankOfficeItemsValue: [BankOfficeTableViewSection] {
        prvBankOfficeItems.value
    }
    
    var loadingStatus: Driver<DataLoadingStatus> {
        prvLoadingStatus.asDriver()
    }
    
    
    init(sceneCoordinator: MvvmSceneCoordinator, networkService: NetworkService, exchange: CurrencyExchange) {
        self.sceneCoordinator = sceneCoordinator
        self.networkService = networkService
        self.exchange = exchange
    }
    
    //    private func loadBankDetailedData() {
    //        print(#function)
    //        guard let url = exchange.bankUrl?.toSiteURL() else {return}
    //        startActivityAnimatingAndLock()
    //
    //        networkService.getBankDetailSeq(url: url).subscribe { [weak self] result in
    //            guard let self = self else {return}
    //            DispatchQueue.printCurrentQueue()
    //
    //            self.officeCellDatas = result.dataTables.map({
    //                ExpandedCellData(isExpanded: false, officeDataTable: $0)
    //            })
    //            self.mapUrl = result.mapUrl
    //
    //            self.shouldBeDisplayedOfficeTableBoxView = true
    //            if UIWindow.isLandscape == false {
    //                // portrait mode
    //                self.showOfficeTableBoxView()
    //            }
    //            print("bank details loaded")
    //        } onFailure: { [weak self] error in
    //            self?.processResponseError(error)
    //        } onDisposed: { [weak self] in
    //            self?.stopActivityAnimatingAndUnlock()
    //        }
    //        .disposed(by: disposeBag)
    //    }
    
    func loadBankOfficeData() {
        print(#function)
        guard let url = exchange.bankUrl?.toSiteURL() else {return}
        //startActivityAnimatingAndLock()
        prvLoadingStatus.accept(.loading)
        
        networkService.getBankDetailSeq(url: url).subscribe { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.printCurrentQueue()
            
//            self.officeCellDatas = result.dataTables.map({
//                ExpandedCellData(isExpanded: false, officeDataTable: $0)
//            })
            
            let sections: [BankOfficeTableViewSection] =  result.dataTables.map({
//                let item1 = BankOfficeTableViewItem.dataItem(officeDataTable: $0)
//                let item2 = BankOfficeTableViewItem.headerItem(text: $0.header)
                
                let item1 = BankOfficeTableViewItemData(officeDataTable: $0)
                let item2 = BankOfficeTableViewItemHeader(text: $0.header)
                
                return BankOfficeTableViewSection(officeItems: [item2, item1])
                
                
            })
            
            self.mapUrl = result.mapUrl
            
//            self.shouldBeDisplayedOfficeTableBoxView = true
//            if UIWindow.isLandscape == false {
//                // portrait mode
//                self.showOfficeTableBoxView()
//            }
            
            self.prvBankOfficeItems.accept(sections)
            
            print("bank details loaded")
        } onFailure: { [weak self] error in
            //self?.processResponseError(error)
            self?.prvLoadingStatus.accept(.fail(error: error))
        } onDisposed: { [weak self] in
            //self?.stopActivityAnimatingAndUnlock()
            print("onDisposed")
            self?.prvLoadingStatus.accept(.success)
        }
        .disposed(by: disposeBag)
    }
    
}


