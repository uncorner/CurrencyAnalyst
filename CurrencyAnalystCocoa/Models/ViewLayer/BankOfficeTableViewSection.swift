//
//  BankOfficeTableViewSection.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 07.11.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import CurrencyAnalystCommon
import RxDataSources

class BankOfficeTableViewItem:  IdentifiableType, Equatable {
    typealias Identity = String
    private let uniqueId = UUID().uuidString
    
    var identity: String {
        uniqueId
    }
    
    static func == (lhs: BankOfficeTableViewItem, rhs: BankOfficeTableViewItem) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }
}

class BankOfficeTableViewItemHeader: BankOfficeTableViewItem {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}

class BankOfficeTableViewItemData: BankOfficeTableViewItem {
    let officeDataTable: DataTable
    
    init(officeDataTable: DataTable) {
        self.officeDataTable = officeDataTable
    }
}

struct BankOfficeTableViewSection  {
    var uniqueId = UUID().uuidString
    var officeItems: [Item]
    var isExpanded: Bool = false
}

extension BankOfficeTableViewSection : AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = BankOfficeTableViewItem
    
    var items: [Item] {
        guard !officeItems.isEmpty else {return []}
        
        if isExpanded {
            return officeItems
        }
        return [officeItems[0]]
    }
    
    var identity: String {
        uniqueId
    }
    
    init(original: Self, items: [BankOfficeTableViewItem]) {
        self = original
        officeItems = items
    }
    
}
