//
//  UserDefaultsExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 20.09.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func setCityId(cityId: String) {
        set(cityId, forKey: UserDefaultsKeys.cityId.rawValue)
    }
    
    func getCityId() -> String? {
        string(forKey: UserDefaultsKeys.cityId.rawValue)
    }
    
}
