//
//  ImageLoader.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 08.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class CachedImageLoader {
    let cache: NSCache<NSString, UIImage>
    let networkService: NetworkService
    let disposeBag = DisposeBag()
    
    init(cache: NSCache<NSString, UIImage>, networkService: NetworkService) {
        self.cache = cache
        self.networkService = networkService
    }
    
    func getImage(imageUrl: URL, completion: @escaping (UIImage?, URL) -> ()) {
        let imagePath = imageUrl.absoluteString
        
        if let image = cache.object(forKey: imagePath as NSString) {
            // get from cache
            completion(image, imageUrl)
        } else {
            let errorCompletion = {
                print("Error image loading \(imageUrl.absoluteURL)")
                completion(nil, imageUrl)
            }
            
            networkService.getImageSeq(url: imageUrl).subscribe { image in
                if let image = image {
                    // set cache
                    self.cache.setObject(image, forKey: imagePath as NSString)
                    completion(image, imageUrl)
                }
                else {
                    errorCompletion()
                }
            } onFailure: { error in
                errorCompletion()
            }
            .disposed(by: disposeBag)
        }
    }
    
}
