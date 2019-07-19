//
//  FlickrApiClient.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/16/19.
//  Copyright © 2019. All rights reserved.
//

import UIKit

typealias SearchPhotosCompletion = ([FlickrPhoto]?, Error?) -> Void

protocol FlickrApiAccessing {
    func getImages(latitude: Double, longitude: Double, completion: @escaping SearchPhotosCompletion)
}

final class FlickrApiClient: FlickrApiAccessing {
    
    private static let apiKey = "YOUR FLICKR API KEY"
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/"
        
        case search(String, String)
        
        var urlString: String {
            switch self {
            case .search(let latitude, let longitude):
                return Endpoints.base + "?method=flickr.photos.search&api_key=\(apiKey)&per_page=20&format=json&lat=\(latitude)&lon=\(longitude)&radius=5"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    func getImages(latitude: Double, longitude: Double, completion: @escaping SearchPhotosCompletion) {
        let latitudeStr = String(format:"%f", latitude)
        let longitudeStr = String(format:"%f", longitude)
        let request = URLRequest(url: Endpoints.search(latitudeStr, longitudeStr).url)
        
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
    
    private func handleResponse(photos: [Photo], completion: @escaping SearchPhotosCompletion) {
        var flickrPhotos = [FlickrPhoto]()
        
        photos.forEach { photo in
            let flickrPhoto = FlickrPhoto(
                photoID: photo.id,
                farm: photo.farm,
                server: photo.server,
                secret: photo.secret
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
        let APIError = NSError(
            domain: "FlickrSearch",
            code: 0,
            userInfo: [NSLocalizedFailureReasonErrorKey: message]
        )
        
        OperationQueue.main.addOperation({
            completion(nil, APIError)
        })
    }
}
