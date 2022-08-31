//
//  OfficeMapViewModel.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 31.08.2022.
//  Copyright © 2022 uncorner. All rights reserved.
//

import Foundation

final class OfficeMapViewModel {
    private let sceneCoordinator: MvvmSceneCoordinator
    
    // TODO
    var mapUrl: URL?
//    var officeGeoDatas: [OfficeGeoData]
    //= [OfficeGeoData]()
    
    init(sceneCoordinator: MvvmSceneCoordinator, mapUrl: URL?) {
        self.sceneCoordinator = sceneCoordinator
        self.mapUrl = mapUrl
    }
    
    //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    // TODO: >>>need to remove
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showMapSegue {
//            guard let destination = segue.destination as? MapViewController else { return }
//            destination.mapUrl = viewModel.mapUrl
//            destination.title = "\(viewModel.exchange.value.bankName) Офисы"
//        }
//    }
    
}

