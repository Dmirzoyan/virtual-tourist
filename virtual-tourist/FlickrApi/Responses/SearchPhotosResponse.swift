//
//  SearchPhotosResponse.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/19/19.
//  Copyright © 2019. All rights reserved.
//

struct SearchPhotosResponse: Codable {
    let photos: PhotosContainer
    let stat: String
}

struct PhotosContainer: Codable {
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}
