//
//  MainViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 21.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxSwift


final class MyViewModel {
    
    //let loading = PublishSubject<Bool>()
    //var exchangeList = PublishSubject<ExchangeListResult>()
    
    var dataSource = PublishSubject<[String]>()
    
    
    func doRequest() {
        //todo
    }
    
}
