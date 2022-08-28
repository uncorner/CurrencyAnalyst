//
//  CoreDataStorageRepository.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 20.08.2022.
//  Copyright © 2022 uncorner. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift

class CoreDataStorageRepository : StorageRepository {
    
    func fetchExchangeListResult() -> Observable<ExchangeListResult> {
        Observable.just(fetchExchangeListResult())
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    
    private func fetchExchangeListResult() -> ExchangeListResult {
        print(#function)
        var result = ExchangeListResult()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return result}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = CurrencyExchangeData.fetchRequest()
        
        var datas = [CurrencyExchangeData]()
        do {
            datas = try context.fetch(fetchRequest)
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let exchanges = datas.map { data -> CurrencyExchange in
            var exchange = CurrencyExchange()
            exchange.bankName = data.bankName ?? ""
            exchange.bankUrl = data.bankUrl ?? ""
            exchange.bankLogoUrl = data.bankLogoUrl ?? ""
            exchange.updatedTime = data.updatedTime ?? ""
            exchange.usdExchange = CurrencyExchangeUnit(amountBuy: data.usdAmountBuy as? Decimal ?? 0, amountSell: data.usdAmountSell as? Decimal ?? 0, isBestBuy: data.usdIsBestBuy, isBestSell: data.usdIsBestSell)
            exchange.euroExchange = CurrencyExchangeUnit(amountBuy: data.euroAmountBuy as? Decimal ?? 0, amountSell: data.euroAmountSell as? Decimal ?? 0, isBestBuy: data.euroIsBestBuy, isBestSell: data.euroIsBestSell)
            return exchange
        }
        
        result.exchanges = exchanges
        return result
    }
    
    func saveExchangeListResult(listResult: ExchangeListResult) {
        print(#function)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try batchDeleteObjects(context: context, entityName: "CurrencyExchangeData")
        } catch let error as NSError {
            print("\(error), \(error.userInfo)")
        }
        
        listResult.exchanges.forEach { exchange in
            let exchangeData = CurrencyExchangeData(context: context)
            exchangeData.bankName = exchange.bankName
            exchangeData.bankLogoUrl = exchange.bankLogoUrl
            exchangeData.bankUrl = exchange.bankUrl
            exchangeData.updatedTime = exchange.updatedTime
            
            exchangeData.usdAmountBuy = (exchange.usdExchange.amountBuy) as NSDecimalNumber
            exchangeData.usdAmountSell = (exchange.usdExchange.amountSell) as NSDecimalNumber
            exchangeData.usdIsBestBuy = exchange.usdExchange.isBestBuy
            exchangeData.usdIsBestSell = exchange.usdExchange.isBestSell
            
            exchangeData.euroAmountBuy = (exchange.euroExchange.amountBuy) as NSDecimalNumber
            exchangeData.euroAmountSell = (exchange.euroExchange.amountSell) as NSDecimalNumber
            exchangeData.euroIsBestBuy = exchange.euroExchange.isBestBuy
            exchangeData.euroIsBestSell = exchange.euroExchange.isBestSell
        }
        
        do {
            try context.save()
            print("managedContext.save() OK")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    private func batchDeleteObjects(context: NSManagedObjectContext, entityName: String) throws {
        // Specify a batch to delete with a fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: entityName)

        // Create a batch delete request for the
        // fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the
        // deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        // Get a reference to a managed object context
        //let context = persistentContainer.viewContext

        // Perform the batch delete
        let batchDelete = try context.execute(deleteRequest)
            as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result
            as? [NSManagedObjectID]
            else { return }

        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]

        // Merge the delete changes into the managed
        // object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
    }
    
    
}
