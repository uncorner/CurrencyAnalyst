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
import Alamofire

class MapViewController: BaseViewController, MvvmBindableType {
    @IBOutlet weak var mapView: GMSMapView!
    
    // TODO
//    var mapUrl: URL?
    private var officeGeoDatas = [OfficeGeoData]()
    
    var viewModel: OfficeMapViewModel!
    
    func bindViewModel() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadOfficeGeoDatas()
    }
    
    private func setMarkers() {
        var markers: [GMSMarker] = []
        for officeData in officeGeoDatas {
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
    
    private func loadOfficeGeoDatas() {
        print(#function)
        guard let url = viewModel.mapUrl else {return}
        
        networkService.getOfficeGeoDatas(url: url).subscribe { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.printCurrentQueue()
            self.officeGeoDatas = result
            self.setMarkers()
            print("office geo datas loaded")
        } onFailure: { [weak self] error in
            self?.processResponseError(error)
        }
        .disposed(by: disposeBag)
    }
    
}
