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

typealias CitySectionModel = SectionModel<Void?, City>

class PickCityViewModel {
    
    private let disposeBag = DisposeBag()
    private let prvFilteredCities: BehaviorRelay<[CitySectionModel]>
    
    // MARK: IN
    var selectedCityId: String?
    let query = PublishRelay<String?>()
    
    // MARK: OUT
    let cities: [City]
    
    var filteredCities: Driver<[CitySectionModel]> {
        prvFilteredCities.asDriver()
    }
    
    init(cities: [City]) {
        self.cities = cities
        
        let firstSectionModel = CitySectionModel(model: nil, items: cities)
        prvFilteredCities = BehaviorRelay<[CitySectionModel]>(value: [firstSectionModel])
        
        query.subscribe(onNext: { [weak self] query in
            guard let self = self else {return}
            let resultCities = self.cities.filter { city in
                city.name.caseInsensitiveHasPrefix(query ?? "")
            }
            
            let sectionModel = CitySectionModel(model: nil, items: resultCities)
            self.prvFilteredCities.accept([sectionModel])
        })
        .disposed(by: disposeBag)
    }
    
}
