//
//  StorageRepository.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 20.08.2022.
//  Copyright © 2022 uncorner. All rights reserved.
//

import Foundation

protocol StorageRepository {
    func saveExchangeListResult(listResult: ExchangeListResult)
    func fetchExchangeListResult() -> ExchangeListResult
    
}
