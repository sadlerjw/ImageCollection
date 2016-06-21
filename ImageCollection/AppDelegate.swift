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
    var window: UIWindow?
    let imageCacheManager = ImageCacheManager()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    

}