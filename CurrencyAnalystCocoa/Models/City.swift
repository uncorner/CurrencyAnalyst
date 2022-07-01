//
//  City.swift
//  CurrencyAnalyst
//
//  Created by denis on 01.06.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation
import RxDataSources

struct City : IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity : String {
        id
    }
    
    var id: String {
        url
    }
    
    var name: String
    var url: String
    var isDefault: Bool
    
}
