//
//  ImageCacheManager.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-21.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import Foundation
import FastImageCache
import Alamofire

@objc class ImageCacheManager : NSObject, FICImageCacheDelegate {
    static let thumbnailFormatName = "com.scatteredcloudsoftware.ImageCollection.thumbnailFormat"
    static let thumbnailFamilyName = "com.scatteredcloudsoftware.ImageCollection.thumbnailFamily"

    private var inflightRequests = [NSURL: Request]()
    
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
        
//        Uncomment to empty the cache on startup, so we're starting from scratch.
//        imageCache.reset()
    }
    
    func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: FICEntity!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
        if let photo = entity as? FlickrPhoto {
            let request = PhotoManager.sharedInstance.downloadThumbnail(photo) { [weak self] image in
                if let url = photo.thumbnailURL {
                    self?.inflightRequests.removeValueForKey(url)
                }
                completionBlock(image)
            }

            if let request = request,
                url = photo.thumbnailURL {
                inflightRequests[url] = request
            }
        } else {
            completionBlock(nil)
        }
    }
    
    func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
        NSLog(errorMessage)
    }
    
    func imageCache(imageCache: FICImageCache!, cancelImageLoadingForEntity entity: FICEntity!, withFormatName formatName: String!) {
        if let photo = entity as? FlickrPhoto,
            url = photo.thumbnailURL,
            request = inflightRequests[url] {
            request.cancel()
            inflightRequests.removeValueForKey(url)
        }
    }
}
