//
//  OfficeMapViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 31.08.2022.
//  Copyright © 2022 uncorner. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

final class OfficeMapViewModel {
    private let sceneCoordinator: MvvmSceneCoordinator
    private let networkService: NetworkService
    private let disposeBag = DisposeBag()
    
    let loadingStatus = BehaviorRelay<DataLoadingStatus>(value: .none)
    var mapUrl: URL?
    let bankName: String
    var officeGeoDatas = [OfficeGeoData]()
    
    init(sceneCoordinator: MvvmSceneCoordinator, networkService: NetworkService, mapUrl: URL?, bankName: String) {
        self.sceneCoordinator = sceneCoordinator
        self.networkService = networkService
        self.mapUrl = mapUrl
        self.bankName = bankName
    }
    
    func loadOfficeGeoDatas() {
        print(#function)
        guard let url = mapUrl else {return}
        loadingStatus.accept(.loading)
        
        networkService.getOfficeGeoDatas(url: url)
            .subscribe { [weak self] datas in
                guard let self = self else {return}
                DispatchQueue.printCurrentQueue()
                self.officeGeoDatas = datas
                self.loadingStatus.accept(.success)
                print("office geo datas loaded")
            } onFailure: { [weak self] error in
                self?.loadingStatus.accept(.fail(error: error))
            } onDisposed: {
                print("onDisposed")
            }
            .disposed(by: disposeBag)
    }
    
}

