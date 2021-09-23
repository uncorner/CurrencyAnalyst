//
//  MainViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 21.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources


struct CustomData {
  var name: String
}

struct SectionOfCustomData {
  var header: String
  var items: [Item]
}

extension SectionOfCustomData: SectionModelType {
  typealias Item = CustomData

   init(original: SectionOfCustomData, items: [Item]) {
    self = original
    self.items = items
  }
}


final class MyViewModel {
    
    //let loading = PublishSubject<Bool>()
    //var exchangeList = PublishSubject<ExchangeListResult>()
    
    var dataSource = PublishSubject<[String]>()
    
    
    func doRequest() {
        //todo
    }
    
}
