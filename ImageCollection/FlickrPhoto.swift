//
//  FlickrPhoto.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import Foundation
import RealmSwift
import FastImageCache

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
            if let farm = farm.value,
                server = server,
                id = id,
                secret = secret {
                let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg"
                return NSURL(string: urlString)
            }
            return nil
        }
    }
    
    var thumbnailURL : NSURL? {
        get {
            if let farm = farm.value,
                server = server,
                id = id,
                secret = secret {
                let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
                return NSURL(string: urlString)
            }
            return nil
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
        return ["photoURL", "thumbnailURL"]
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

extension FlickrPhoto : FICEntity {
    var UUID : String! {
        return FICStringWithUUIDBytes(FICUUIDBytesWithString(id))
    }
    
    var sourceImageUUID : String! {
        return FICStringWithUUIDBytes(FICUUIDBytesWithString(thumbnailURL?.absoluteString))
    }
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return photoURL
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        return { (context: CGContext!, size: CGSize) -> Void in
            let contextBounds = CGRect(origin: CGPoint(), size: size)
            
            // We want to crop and scale the image so if fills the destination
            let scaleFactor = max(size.height / image.size.height, size.width / image.size.width)
            let destinationSize = CGSize(width: image.size.width * scaleFactor, height: image.size.height * scaleFactor)
            let destinationOrigin = CGPoint(x: 0 - (destinationSize.width - contextBounds.width) / 2, y: 0 - (destinationSize.height - contextBounds.height) / 2)
            let destinationBounds = CGRect(origin: destinationOrigin, size: destinationSize)
                
            
            CGContextClearRect(context, contextBounds)
            UIGraphicsPushContext(context)
            image.drawInRect(destinationBounds)
            UIGraphicsPopContext()
        }
    }
}
