//
//  AppDelegate.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import UIKit
import FastImageCache

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let thumbnailFormatName = "com.scatteredcloudsoftware.ImageCollection.thumbnailFormat"
    static let thumbnailFamilyName = "com.scatteredcloudsoftware.ImageCollection.thumbnailFamily"
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupFastImageCache()
        return true
    }
    
    func setupFastImageCache() {
        let thumbnailFormat = FICImageFormat()
        thumbnailFormat.name = AppDelegate.thumbnailFormatName
        thumbnailFormat.family = AppDelegate.thumbnailFamilyName
        thumbnailFormat.style = .Style32BitBGR
        thumbnailFormat.imageSize = ImageCollectionViewController.photoSize()
        thumbnailFormat.maximumCount = 250
        thumbnailFormat.devices = [.Pad, .Phone]
        
        let imageCache = FICImageCache.sharedImageCache()
        imageCache.delegate = self
        imageCache.setFormats([thumbnailFormat])
    }
}

extension AppDelegate : FICImageCacheDelegate {
    func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: FICEntity!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
        if let photo = entity as? FlickrPhoto {
            PhotoManager.sharedInstance.downloadPhoto(photo, callback: completionBlock)
        } else {
            completionBlock(nil)
        }
    }
    
    func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
        NSLog(errorMessage)
    }
}
