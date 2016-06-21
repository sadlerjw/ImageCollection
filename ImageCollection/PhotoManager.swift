//
//  PhotoManager.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-21.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import Foundation
import RealmSwift
import Alamofire

class PhotoManager {
    let processingQueue = dispatch_queue_create("photoManagerProcessingQueue", DISPATCH_QUEUE_CONCURRENT)
    
    func refreshPhotosFromFlickr() {
        Alamofire.request(Router.PhotosForUser(userID: "51442062@N04"))
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON(queue: processingQueue) { response in
                switch response.result {
                case .Success(let rootObject):
                    let photosWrapper = rootObject["photos"] as? [String: AnyObject]
                    //                let page = photosWrapper?["page"] as? Int
                    //                let pages = photosWrapper?["pages"] as? Int
                    
                    if let photoDicts = photosWrapper?["photo"] as? [[String: AnyObject]] {
                        // TODO: instantiate in a realm-capable way
                        let photos = photoDicts.flatMap(FlickrPhoto.init(fromDictionary:))
                        
                        do {
                            let realm = try Realm()
                            
                            try realm.write {
                                realm.add(photos, update: true)
                            }
                        } catch let e {
                            NSLog("\(e)")
                            // TODO
                        }
                    }
                case .Failure(_):
                    // TODO
                    break
                }
        }

    }
}