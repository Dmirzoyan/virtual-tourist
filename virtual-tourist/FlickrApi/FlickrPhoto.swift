//
//  FlickrImage.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/16/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

final class FlickrPhoto {
    
    let id: String
    var thumbnail: UIImage?
    
    private let farm: Int
    private let server: String
    private let secret: String
    
    init(photoID: String, farm: Int, server: String, secret: String) {
        self.id = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
    }
    
    enum ImageSize: String {
        case medium = "m"
        case base = "b"
    }
    
    func imageUrl(_ size: ImageSize = .medium) -> URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size.rawValue).jpg")
    }
}
