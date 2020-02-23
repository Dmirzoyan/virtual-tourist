//
//  FlickrApiClient.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/16/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

typealias SearchPhotosCompletion = ([FlickrPhoto]?, Error?) -> Void

//sourcery: mock
protocol FlickrApiAccessing {
    func getImages(latitude: Double, longitude: Double, completion: @escaping SearchPhotosCompletion)
}

final class FlickrApiClient: FlickrApiAccessing {
    
    private static let apiKey = "FLICKR_API_KEY_PLACEHOLDER"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        
        case search(String, String, Int)
        
        var urlString: String {
            switch self {
            case .search(let latitude, let longitude, let page):
                return Endpoints.base + "?method=flickr.photos.search&api_key=\(apiKey)&per_page=15&format=json&lat=\(latitude)&lon=\(longitude)&radius=10&tags=architecture&page=\(page)"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    func getImages(latitude: Double, longitude: Double, completion: @escaping SearchPhotosCompletion) {
        let latitudeStr = String(format:"%f", latitude)
        let longitudeStr = String(format:"%f", longitude)
        let request = URLRequest(url: Endpoints.search(latitudeStr, longitudeStr, Int.random(in: 1 ..< 7)).url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let _ = response as? HTTPURLResponse,
                let data = data,
                error == nil
            else {
                self.reportError("Unknown API response", completion: completion)
                return
            }
            
            let range = 14 ..< (data.count - 1)
            let payload = data.subdata(in: range)
            
            if let responseObject = try? JSONDecoder().decode(SearchPhotosResponse.self, from: payload) {
                self.handleResponse(photos: responseObject.photos.photo, completion: completion)
            } else if let responseObject = try? JSONDecoder().decode(SearchPhotosFailedResponse.self, from: payload) {
                self.reportError(responseObject.message, completion: completion)
            } else {
                self.reportError("Unknown API response", completion: completion)
            }
        }
        task.resume()
    }
    
    private func handleResponse(photos: [PhotoResponse], completion: @escaping SearchPhotosCompletion) {
        var flickrPhotos = [FlickrPhoto]()
        
        photos.forEach { photo in
            let flickrPhoto = FlickrPhoto(
                photoID: photo.id,
                farm: photo.farm,
                server: photo.server,
                secret: photo.secret,
                title: photo.title
            )
            
            if let url = flickrPhoto.imageUrl(),
                let imageData = try? Data(contentsOf: url as URL),
                let image = UIImage(data: imageData) {
                flickrPhoto.thumbnail = image
                flickrPhotos.append(flickrPhoto)
            }
        }
        
        OperationQueue.main.addOperation({
            completion(flickrPhotos, nil)
        })
    }
    
    private func reportError(_ message: String, completion: @escaping SearchPhotosCompletion) {
        let apiError = NSError(
            domain: "FlickrSearch",
            code: 0,
            userInfo: [NSLocalizedFailureReasonErrorKey: message]
        )
        
        OperationQueue.main.addOperation({
            completion(nil, apiError)
        })
    }
}
