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

/*
enum BankOfficeTableViewItem {
    case dataItem(officeDataTable: DataTable)
    case headerItem(text: String, isExpanded: Bool)
}

struct BankOfficeTableViewSection {
    //var header: String
    //var items: [Item]
    //var isExpanded: Bool = false
    var officeItems: [Item]
    
//    var headerItem: BankOfficeTableViewItem
//    var dataItem: BankOfficeTableViewItem
    
    //var officeDataTable: DataTable
}

extension BankOfficeTableViewSection: SectionModelType {
    typealias Item = BankOfficeTableViewItem
    
    var items: [Item] {
        let headerItem = officeItems[0]
        if case let .headerItem(_, isExpanded) = headerItem, !isExpanded {
            return [headerItem]
        }
        
        return officeItems
    }

    init(original: Self, items: [BankOfficeTableViewItem] ) {
        self = original
        //self.items = items
        self.officeItems = items
    }

}
 */


//>>>>>>>>>>>>>>>>>>>>>>>>>>

//enum BankOfficeTableViewItem {
//    case dataItem(officeDataTable: DataTable)
//    case headerItem(text: String /*, isExpanded: Bool*/)
//}

class BankOfficeTableViewItem:  IdentifiableType, Equatable {
    typealias Identity = String
    //private let
    var uniqueId = UUID().uuidString
    
    var identity: String {
        uniqueId
    }
    
    static func == (lhs: BankOfficeTableViewItem, rhs: BankOfficeTableViewItem) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }
}

class BankOfficeTableViewItemHeader: BankOfficeTableViewItem {
    let text: String
    //let uniqueId = UUID().uuidString
    
    init(text: String) {
        self.text = text
    }
}

class BankOfficeTableViewItemData: BankOfficeTableViewItem {
    let officeDataTable: DataTable
    //let uniqueId = UUID().uuidString

    init(officeDataTable: DataTable) {
        self.officeDataTable = officeDataTable
    }
}

struct BankOfficeTableViewSection  {
    var uniqueId = UUID().uuidString
    var officeItems: [Item]
    var isExpanded: Bool = false
}

extension BankOfficeTableViewSection : /*SectionModelType*/ AnimatableSectionModelType {
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

//struct BankOfficeTableViewSection {
//    var isExpanded: Bool = false
//    var officeItems: [Item]
//}
//
//extension BankOfficeTableViewSection: SectionModelType {
//    typealias Item = BankOfficeTableViewItem
//
//    var items: [Item] {
//        if officeItems.isEmpty {
//            return []
//        }
//
//        if isExpanded {
//            return officeItems
//        }
//        return [officeItems[0]]
//    }
//
//    init(original: Self, items: [BankOfficeTableViewItem]) {
//        self = original
//        self.officeItems = items
//    }
//
//}


//enum ExchangeTableViewItem {
//    case ExchangeItem(exchange: CurrencyExchange)
//    case HeadItem(cityName: String)
//}
//
//struct ExchangeTableViewSection {
//  //var header: String
//  var items: [Item]
//}
//
//extension ExchangeTableViewSection: SectionModelType {
//    typealias Item = ExchangeTableViewItem
//
//    init(original: Self, items: [ExchangeTableViewItem]) {
//        self = original
//        self.items = items
//    }
//
//}
