//
//  FlickrPhoto.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import Foundation
import RealmSwift

class FlickrPhoto: Object {
    dynamic var id : String?
    dynamic var owner : String?
    dynamic var secret : String?
    dynamic var server : String?
    var farm = RealmOptional<Int32>()
    dynamic var title : String?
    let isPublic = RealmOptional<Bool>()
    let isFriend = RealmOptional<Bool>()
    let isFamily = RealmOptional<Bool>()
    
    var photoURL : NSURL? {
        get {
            return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")
        }
    }
}

// Realm-specific stuff
extension FlickrPhoto {
    override static func primaryKey() -> String {
        return "id"
    }
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
    override static func ignoredProperties() -> [String] {
        return ["photoURL"]
    }
}

// Parsing from dictionaries
extension FlickrPhoto {
    convenience init?(fromDictionary dictionary: [String: AnyObject]) {
        self.init()
        
        id = dictionary["id"] as? String
        owner = dictionary["owner"] as? String
        secret = dictionary["secret"] as? String
        server = dictionary["server"] as? String
        if let farm = dictionary["farm"] as? Int {
            self.farm.value = Int32(farm)
        }
        title = dictionary["title"] as? String
        isPublic.value = dictionary["ispublic"] as? Bool
        isFriend.value = dictionary["isfriend"] as? Bool
        isFamily.value = dictionary["isfamily"] as? Bool
        
        if id == nil
            || owner == nil
            || secret == nil
            || server == nil
            || farm.value == nil
            || title == nil
            || isPublic.value == nil
            || isFriend.value == nil
            || isFamily.value == nil {
            return nil
        }
    }
}