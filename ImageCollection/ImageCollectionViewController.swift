//
//  ImageCollectionViewController.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class ImageCollectionViewController: UICollectionViewController {

    let photoManager = PhotoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.refreshPhotosFromFlickr()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

