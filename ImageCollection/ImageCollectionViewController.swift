//
//  ImageCollectionViewController.swift
//  ImageCollection
//
//  Created by Jason Sadler on 2016-06-20.
//  Copyright © 2016 Scattered Cloud Software. All rights reserved.
//

import UIKit
import RealmSwift
import FastImageCache

class ImageCollectionViewController : UICollectionViewController {

    let photoManager = PhotoManager.sharedInstance
    let imageCache = FICImageCache.sharedImageCache()
    var realm : Realm!
    var photos : Results<FlickrPhoto>!
    var notificationToken : NotificationToken?
    
    static let idealSpacing : CGFloat = 10
    static let idealNumberOfItemsPerLine = 3
    static func photoSize() -> CGSize {
        let screenBounds = UIScreen.mainScreen().bounds
        let width = (min(screenBounds.width, screenBounds.height) - CGFloat(idealNumberOfItemsPerLine - 1) * idealSpacing) / CGFloat(idealNumberOfItemsPerLine)
        return CGSize(width: width, height: width)
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.refreshPhotosFromFlickr()
        
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = ImageCollectionViewController.idealSpacing
        layout.minimumLineSpacing = ImageCollectionViewController.idealSpacing
        layout.itemSize = ImageCollectionViewController.photoSize()
        
        do {
            realm = try Realm()
            photos = realm.objects(FlickrPhoto)
            notificationToken = photos.addNotificationBlock { [weak collectionView] change in
                switch change {
                case .Initial(_):
                    collectionView?.reloadSections(NSIndexSet(index: 0))
                case .Update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                    collectionView?.performBatchUpdates({
                        collectionView?.deleteItemsAtIndexPaths(deletions.map { NSIndexPath(forItem: $0, inSection: 0) })
                        collectionView?.insertItemsAtIndexPaths(insertions.map { NSIndexPath(forItem: $0, inSection: 0) })
                        collectionView?.reloadItemsAtIndexPaths(modifications.map { NSIndexPath(forItem: $0, inSection: 0) })
                        }, completion: nil)
                case .Error(let error):
                    // TODO
                    NSLog("\(error)")
                }
            }

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
        cell.imageView.image = nil
        
        if let oldPhoto = cell.photo {
            imageCache.cancelImageRetrievalForEntity(oldPhoto, withFormatName: ImageCacheManager.thumbnailFormatName)
        }
        
        if let photo = photoAtIndexPath(indexPath) {
            cell.photo = photo
            imageCache.asynchronouslyRetrieveImageForEntity(photo, withFormatName: ImageCacheManager.thumbnailFormatName) { (photo, formatName, image) in
                cell.imageView.image = image
                cell.imageView.layer.addAnimation(CATransition(), forKey: kCATransition)
            }
        }
        return cell
    }
}

extension ImageCollectionViewController : UICollectionViewDelegateFlowLayout /*, UICollectionViewDelegate*/ {
    
}
