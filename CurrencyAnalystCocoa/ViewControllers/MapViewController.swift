//
//  MapViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 03.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift

class MapViewController: BaseViewController, MvvmBindableType {
    @IBOutlet weak var mapView: GMSMapView!
    var viewModel: OfficeMapViewModel!
    
    func bindViewModel() {
        viewModel.loadingStatus
            .asDriver()
            .drive(onNext: { [weak self] status in
                guard let self = self else {return}
                switch status {
                case .loading:
                    self.startActivityAnimatingAndLock()
                case .success:
                    self.setMarkers()
                    self.stopActivityAnimatingAndUnlock()
                case .fail(let error):
                    self.stopActivityAnimatingAndUnlock()
                    self.processResponseError(error)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(viewModel.bankName) Офисы"
        viewModel.loadOfficeGeoDatas()
    }
    
    private func setMarkers() {
        var markers: [GMSMarker] = []
        for officeData in viewModel.officeGeoDatas {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: officeData.latitude, longitude: officeData.longitude)

            marker.title = officeData.bankName
            if officeData.officeName.isEmptyOrWhitespace() {
                marker.snippet = officeData.address
            }
            else {
                marker.snippet = "\(officeData.officeName)\n\(officeData.address)"
            }

            marker.icon = GMSMarker.markerImage(with: Styles.MapViewController.markerColor)
            marker.map = mapView
            markers.append(marker)
        }

        if (markers.count > 1) {
            var bounds = GMSCoordinateBounds()
            for marker in markers
            {
                bounds = bounds.includingCoordinate(marker.position)
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 30)
            mapView.animate(with: update)
        }
        else if markers.count == 1 {
            let update = GMSCameraUpdate.setTarget(markers[0].position, zoom: 15.0)
            mapView.animate(with: update)
        }
    }
    
}
