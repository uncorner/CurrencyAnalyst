//
//  CurrencyExchangeData+CoreDataProperties.swift
//  
//
//  Created by denis on 21.08.2022.
//
//

import Foundation
import CoreData


extension CurrencyExchangeData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyExchangeData> {
        return NSFetchRequest<CurrencyExchangeData>(entityName: "CurrencyExchangeData")
    }

    @NSManaged public var bankLogoUrl: String?
    @NSManaged public var bankName: String?
    @NSManaged public var bankUrl: String?
    @NSManaged public var euroAmountBuy: NSDecimalNumber?
    @NSManaged public var euroAmountSell: NSDecimalNumber?
    @NSManaged public var euroIsBestBuy: Bool
    @NSManaged public var euroIsBestSell: Bool
    @NSManaged public var updatedTime: String?
    @NSManaged public var usdAmountBuy: NSDecimalNumber?
    @NSManaged public var usdAmountSell: NSDecimalNumber?
    @NSManaged public var usdIsBestBuy: Bool
    @NSManaged public var usdIsBestSell: Bool

}
