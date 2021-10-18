//
//  extension.swift
//  chatDare
//
//  Created by Ramon Yepez on 10/17/21.
//

import Foundation
import UIKit
import Firebase


let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    
    func loadImageUsingCachedwithUrl(photoURL: String){
        
        if let cachedImage = imageCache.object(forKey: photoURL as NSString) {
            self.image = cachedImage
            
            return
        }
    }
    
    //otherwise download images

   
}
