//
//  ImageLoader.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 08.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import UIKit

class CachedImageLoader {
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
    }
    
    func getImage(imageUrl: URL, completion: @escaping (UIImage?, URL) -> ()) {
        let imagePath = imageUrl.absoluteString
        
        if let image = cache.object(forKey: imagePath as NSString) {
            completion(image, imageUrl)
        } else {
            task = session.downloadTask(with: imageUrl, completionHandler: { (location, response, error) in
                if error == nil, let data = try? Data(contentsOf: imageUrl) {
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
            })
            
            task.resume()
        }
    }
    
}
