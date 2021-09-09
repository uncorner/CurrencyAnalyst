//
//  ImageLoader.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 08.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class CachedImageLoader {
    var cache: NSCache<NSString, UIImage> = NSCache()
    
    func getImage(imageUrl: URL, completion: @escaping (UIImage?, URL) -> ()) {
        let imagePath = imageUrl.absoluteString
        
        if let image = cache.object(forKey: imagePath as NSString) {
            // get from cache
            completion(image, imageUrl)
        } else {
            AF.request(imageUrl).responseData { response in
                if response.error == nil, let data = response.value {
                    if let image = UIImage(data: data) {
                        // set cache
                        self.cache.setObject(image, forKey: imagePath as NSString)
                        completion(image, imageUrl)
                    }
                    else {
                        completion(nil, imageUrl)
                    }
                }
                else {
                    completion(nil, imageUrl)
                }
            }
        }
        
    }
    
}
