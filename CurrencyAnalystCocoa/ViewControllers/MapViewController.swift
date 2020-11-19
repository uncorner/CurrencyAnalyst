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

class MapViewController: BaseViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var mapUrl: URL?
    private var officeGeoDatas = [OfficeGeoData]()
    
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
        guard let url = mapUrl else {return}
        
        AF.request(url).validate()
            .responseString(completionHandler: { [weak self] response in
                guard let strongSelf = self else {return}
                
                switch response.result {
                case .success(let value):
                    let dataSource = strongSelf.getExchangeDataSource()
                    var result: [OfficeGeoData]
                    do {
                        result = try dataSource.getOfficeGeoDatas(html: value)
                    }
                    catch {
                        strongSelf.processError(error)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        strongSelf.officeGeoDatas = result
                        strongSelf.setMarkers()
                    }
                case .failure(let error):
                    print(error)
                    strongSelf.processError(error)
                }
            })
    }
    
}
