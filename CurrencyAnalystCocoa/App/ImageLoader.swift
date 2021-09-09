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
    
    func getImage(imageUrl: URL, completion: @escaping (UIImage?, URL) -> ()) {
        let imagePath = imageUrl.absoluteString
        
        if let image = cache.object(forKey: imagePath as NSString) {
            // found in cache
            //DispatchQueue.main.async {
            completion(image, imageUrl)
            //}
        } else {
            task = session.downloadTask(with: imageUrl, completionHandler: { (location, response, error) in
                if error == nil, let data = try? Data(contentsOf: imageUrl) {
                    if let image = UIImage(data: data) {
                        // set cache
                        self.cache.setObject(image, forKey: imagePath as NSString)
                        //DispatchQueue.main.async {
                        completion(image, imageUrl)
                        //}
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
    
    //    func getImageWithPath(imagePath: String, completionHandler: @escaping (UIImage,String) -> ()) {
    //        if let image = cache.object(forKey: imagePath as NSString) {
    //            DispatchQueue.main.async {
    //                completionHandler(image, imagePath)
    //            }
    //        } else {
    ////            if imagePath == "https://kovalut.ru/banklogo/balakovo-bank.png?1630431881" {
    ////                let a = 1
    ////            }
    //
    //            // >>>>>>>>>>> temp
    //            let placeholder = #imageLiteral(resourceName: "dollar_image-1")
    //                //#imageLiteral(resourceName: "settings_image-1")
    //            DispatchQueue.main.async {
    //                completionHandler(placeholder, imagePath)
    //            }
    //
    //            let url: URL! = URL(string: imagePath)
    //            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
    //                if let data = try? Data(contentsOf: url) {
    //                    let img: UIImage! = UIImage(data: data)
    //                    self.cache.setObject(img, forKey: imagePath as NSString)
    //
    //                    DispatchQueue.main.async {
    //                        completionHandler(img, imagePath)
    //                    }
    //                }
    //            })
    //
    //            task.resume()
    //        }
    //    }
    
    
}
