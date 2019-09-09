//
//  ImageCachable.swift
//  TwitchTopGames
//
//  Created by Felipe Bassi on 08/09/19.
//  Copyright © 2019 fbassi. All rights reserved.
//

import Foundation
import UIKit

protocol ImageCachable {}
let imageCache = NSCache<NSString, UIImage>()


extension UIImageView: ImageCachable {}

extension ImageCachable where Self: UIImageView {
    
    typealias SuccessCompletion = (Bool) -> ()
    
    func loadImageUsingCacheWithURL(_ URL: URL?, placeHolder: UIImage?, completion: @escaping SuccessCompletion) {
        
        self.image = nil
        if URL == nil {
            self.image = placeHolder
            return
        }
        
        if let cachedImage = imageCache.object(forKey: NSString(string: URL!.absoluteString)) {
            DispatchQueue.main.async {
                self.image = cachedImage
                completion(true)
            }
            return
        }
        self.image = placeHolder
        
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: URL!, completionHandler: { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return
                }
                if httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        if let downloadedImage = UIImage(data: data) {
                            imageCache.setObject(downloadedImage, forKey: NSString(string: URL!.absoluteString))
                            DispatchQueue.main.async {
                                self.image = downloadedImage
                                completion(true)
                            }
                        }
                    }
                } else {
                    self.image = placeHolder
                }
            }).resume()
        }
    }
}


