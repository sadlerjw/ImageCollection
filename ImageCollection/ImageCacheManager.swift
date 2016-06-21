//
//  ImageCacheManager.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-21.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import Foundation
import FastImageCache

@objc class ImageCacheManager : NSObject, FICImageCacheDelegate {
    static let thumbnailFormatName = "com.scatteredcloudsoftware.ImageCollection.thumbnailFormat"
    static let thumbnailFamilyName = "com.scatteredcloudsoftware.ImageCollection.thumbnailFamily"
    
    override init() {
        super.init()
        let thumbnailFormat = FICImageFormat()
        thumbnailFormat.name = ImageCacheManager.thumbnailFormatName
        thumbnailFormat.family = ImageCacheManager.thumbnailFamilyName
        thumbnailFormat.style = .Style32BitBGR
        thumbnailFormat.imageSize = ImageCollectionViewController.photoSize()
        thumbnailFormat.maximumCount = 250
        thumbnailFormat.devices = [.Pad, .Phone]
        
        let imageCache = FICImageCache.sharedImageCache()
        imageCache.delegate = self
        imageCache.setFormats([thumbnailFormat])
    }
    
    func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: FICEntity!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
        if let photo = entity as? FlickrPhoto {
            PhotoManager.sharedInstance.downloadThumbnail(photo) { image in
                completionBlock(image)
            }
        } else {
            completionBlock(nil)
        }
    }
    
    func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
        NSLog(errorMessage)
    }
}
