//
//  CachedImageView.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/28/22.
//

import UIKit

class CachedImageView: UIImageView {
    
    private var imageUrlString: String?

    func loadImaveWithUrl(_ url: URL) {
        
        imageUrlString = url.absoluteString
        
        self.image = nil
        
        if let cachedImage =  ImageCache.shared.getCachedImage(forKey: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            if let error = error {
                print(error)
            }
            
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async { [weak self] in
                    //this is to prevent displaying incorrect images when scrolling fast
                    if self?.imageUrlString == url.absoluteString {
                        self?.image = downloadedImage
                    }
                }
                ImageCache.shared.cacheImage(downloadedImage, forKey: url.absoluteString)
            }
        }).resume()
    }

}
