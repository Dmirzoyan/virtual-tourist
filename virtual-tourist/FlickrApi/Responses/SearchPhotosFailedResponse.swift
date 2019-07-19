//
//  SearchPhotosFailedResponse.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/19/19.
//  Copyright © 2019. All rights reserved.
//

struct SearchPhotosFailedResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}
