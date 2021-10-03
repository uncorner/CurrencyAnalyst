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
import RxDataSources

typealias CitySectionModel = SectionModel<String, City>

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
    //private let prvFilteredCities: BehaviorRelay<[City]>
    private let prvFilteredCities: BehaviorRelay<[CitySectionModel]>
    
//    var filteredCities: Driver<[City]> {
//        prvFilteredCities.asDriver()
//    }
    
    var filteredCities: Driver<[CitySectionModel]> {
        prvFilteredCities.asDriver()
    }
    
//    var filteredCitiesValue: [City] {
//        prvFilteredCities.value
//    }
    
    init(cities: [City]) {
        self.prvCities = cities
        //prvFilteredCities = BehaviorRelay<[City]>(value: cities)
        
        let firstSectionModel = CitySectionModel(model: "города", items: cities)
        prvFilteredCities = BehaviorRelay<[CitySectionModel]>(value: [firstSectionModel])
        
        query.subscribe(onNext: { [weak self] query in
            guard let self = self else {return}
            let resultCities = self.prvCities.filter { city in
                city.name.caseInsensitiveHasPrefix(query ?? "")
            }
            
            //self.prvFilteredCities.accept(resultCities)
            let sectionModel = CitySectionModel(model: "города", items: resultCities)
            self.prvFilteredCities.accept([sectionModel])
        })
        .disposed(by: disposeBag)
        
    }
    
}
