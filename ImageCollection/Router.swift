//
//  Router.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import Foundation
import Alamofire

// Adopted directly from Alamofire's README ("API Parameter Abstraction")
enum Router: URLRequestConvertible {
    static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "e6ce2ae712060be8f036215faf1b9845"
    private static let secret = "9f4eee482ab47ceb"
    
    case PhotosForUser(userID: String, page: Int)
    
    var URLRequest: NSMutableURLRequest {
        get {
            let parameters: [String: AnyObject] = {
                var params : [String: AnyObject] = [
                    "api_key": Router.apiKey,
                    "format": "json",
                    "nojsoncallback": true
                ]
                
                switch self {
                case .PhotosForUser(let userID, let page):
                    params["method"] = "flickr.people.getPublicPhotos"
                    params["user_id"] = userID
                    params["page"] = page
                }
                
                return params
            }()
            
            let URL = NSURL(string: Router.baseURLString)!
            let URLRequest = NSURLRequest(URL: URL)
            let encoding = Alamofire.ParameterEncoding.URL
            
            return encoding.encode(URLRequest, parameters: parameters).0
        }
    }
}