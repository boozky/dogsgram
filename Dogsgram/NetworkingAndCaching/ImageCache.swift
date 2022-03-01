//
//  ImageCache.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/27/22.
//

import Foundation
import UIKit

//this is an abstraction layer on top of cache so it's easier to change caching mechanizm if needed
class ImageCache {
    static var shared = ImageCache()
    
    private var imageCache = NSCache<NSString, UIImage>()
    
    public func getCachedImage(forKey: String) -> UIImage? {
        if let cacheImage = imageCache.object(forKey: NSString(string: forKey)) {
            return cacheImage
        }
        return nil
    }
    
    public func cacheImage(_ image: UIImage, forKey: String) {
        imageCache.setObject(image, forKey: NSString(string: forKey))
    }
}

