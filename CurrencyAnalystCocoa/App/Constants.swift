//
//  Constants.swift
//  CurrencyAnalyst
//
//  Created by denis2 on 14.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    static let defaultCityId = "/kurs/moskva/"
    static let commonErrorMessage = "Произошла ошибка. Действие не может быть выполнено."
    static let rateStub = "----"
    
    struct Urls {
        static let sourceSiteUrl = "https://kovalut.ru/"
        static let citiesUrl = "https://kovalut.ru/cities.htm"
    }
    
    struct Notifications {
        static let didEnterBackground = Notification.Name("DidEnterBackground")
    }
    

}
