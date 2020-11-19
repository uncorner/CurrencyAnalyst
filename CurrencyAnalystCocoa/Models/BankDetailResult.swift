//
//  BankDetailResult.swift
//  CurrencyAnalyst
//
//  Created by denis on 03.04.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation
import CurrencyAnalystCommon

class BankDetailResult {
    var dataTables: [DataTable]
    var mapUrl: URL?
    
    init(dataTables: [DataTable], mapUrl: URL?) {
        self.dataTables = dataTables
        self.mapUrl = mapUrl
    }
    
    init() {
        dataTables = []
    }
}
