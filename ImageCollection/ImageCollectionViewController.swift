//
//  ImageCollectionViewController.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import UIKit
import Alamofire

class ImageCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(Router.PhotosForUser(userID: "51442062@N04"))
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            switch response.result {
            case .Success(let rootObject):
                let photosWrapper = rootObject["photos"] as? [String: AnyObject]
//                let page = photosWrapper?["page"] as? Int
//                let pages = photosWrapper?["pages"] as? Int
                
                if let photoDicts = photosWrapper?["photo"] as? [[String: AnyObject]] {
                    // TODO: instantiate in a realm-capable way
                    let photos = photoDicts.flatMap(FlickrPhoto.init(fromDictionary:))
                    debugPrint(photos)
                }
            case .Failure(_):
                // TODO
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

