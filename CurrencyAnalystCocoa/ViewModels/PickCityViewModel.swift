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

typealias CitySectionModel = AnimatableSectionModel<String, City>

class PickCityViewModel {
    private static let section1 = "section_1"
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
        
        let sectionModel = CitySectionModel(model: Self.section1, items: cities)
        prvFilteredCities = BehaviorRelay<[CitySectionModel]>(value: [sectionModel])
        
        query.throttle(.milliseconds(200), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map({ queryText in
                queryText?.trimming()
            })
            .subscribe(onNext: { [weak self] queryText in
                guard let self = self else {return}
                
                var resultCities: [City] = self.cities
                if let queryText = queryText, queryText.isEmpty == false {
                    resultCities = self.cities.filter { city in
                        city.name.caseInsensitiveHasPrefix(queryText)
                    }
                }
                
                let sectionModel = CitySectionModel(model: Self.section1, items: resultCities)
                self.prvFilteredCities.accept([sectionModel])
            })
            .disposed(by: disposeBag)
    }
    
}
