//
//  ImageLoader.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 08.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import UIKit


class ImageLoader {
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
    }
    
    func obtainImageWithPath(imagePath: String, completionHandler: @escaping (UIImage,String) -> ()) {
        if let image = cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image, imagePath)
            }
        } else {
//            if imagePath == "https://kovalut.ru/banklogo/balakovo-bank.png?1630431881" {
//                let a = 1
//            }
            
            // >>>>>>>>>>> temp
            let placeholder = #imageLiteral(resourceName: "dollar_image-1")
                //#imageLiteral(resourceName: "settings_image-1")
            DispatchQueue.main.async {
                completionHandler(placeholder, imagePath)
            }
            
            let url: URL! = URL(string: imagePath)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    let img: UIImage! = UIImage(data: data)
                    self.cache.setObject(img, forKey: imagePath as NSString)
                    
                    DispatchQueue.main.async {
                        completionHandler(img, imagePath)
                    }
                }
            })
            
            task.resume()
        }
    }
}
