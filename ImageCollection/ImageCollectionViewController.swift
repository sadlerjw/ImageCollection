//
//  ImageCollectionViewController.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import UIKit
import RealmSwift

class ImageCollectionViewController : UICollectionViewController {

    let photoManager = PhotoManager()
    var realm : Realm!
    var photos : Results<FlickrPhoto>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.refreshPhotosFromFlickr()
        
        do {
            realm = try Realm()
            photos = realm.objects(FlickrPhoto)
        } catch let e {
            // TOOD
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ImageCollectionViewController /*: UICollectionViewDataSource*/ {
    func photoAtIndexPath(indexPath: NSIndexPath) -> FlickrPhoto? {
        let item = indexPath.indexAtPosition(1)
        if item >= 0 && item < photos.count {
            return photos[item]
        }
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        if let photo = photoAtIndexPath(indexPath) {
            cell.label.text = photo.title
        } else {
            cell.label.text = "Ruh-roh"
        }
        return cell
    }
}

extension ImageCollectionViewController : UICollectionViewDelegateFlowLayout /*, UICollectionViewDelegate*/ {
    
}
