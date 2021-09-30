//
//  DataLoadingStatus.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 30.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation

enum DataLoadingStatus {
    case none
    case loading
    case success
    case fail(error: Error)
}

