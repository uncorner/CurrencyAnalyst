//
//  PickCityViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 02.10.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PickCityViewModel {
    
    private let disposeBag = DisposeBag()
    
    // MARK: IN
    private var prvCities = [City]()
    var selectedCityId: String?
    
    //var query: String?
    let query = PublishSubject<String?>()
    
    var cities: [City] {
        prvCities
    }
    
    // MARK: OUT
    //var filteredCities = [City]()
    private let prvFilteredCities: BehaviorRelay<[City]>
    
    var filteredCities: Driver<[City]> {
        prvFilteredCities.asDriver()
    }
    
    var filteredCitiesValue: [City] {
        prvFilteredCities.value
    }
    
    init(cities: [City]) {
        self.prvCities = cities
        prvFilteredCities = BehaviorRelay<[City]>(value: cities)
        
        query.subscribe(onNext: { [weak self] query in
            guard let self = self else {return}
            let resultCities = self.prvCities.filter { city in
                city.name.caseInsensitiveHasPrefix(query ?? "")
            }
            
            self.prvFilteredCities.accept(resultCities)
        })
        .disposed(by: disposeBag)
        
    }
    
}
