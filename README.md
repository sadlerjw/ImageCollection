ImageCollection
===

A simple little image collection viewer, created as a job interview exercise! Loads all of a Flickr user's public photos into a `UICollectionView`.

Running the app
---
3rd party libraries are pulled in using [Cocoapods](https://cocoapods.org), and are checked into source control as per the Cocoapods [recommendations](https://guides.cocoapods.org/using/using-cocoapods.html).

That means it's important to open up the **xcworkspace**, not the xcproject file, but other than that you should be able to build and run the app without any other intermediate steps.

A few important notes for poking around the app:

- The user whose photos are used is defined at the top of `PhotoManager.swift`. If you change this you'll also want to clear your database and image cache on next launch:
- There's some code you can uncomment in `PhotoManager.init` in order to use an empty database on startup.
- There's a line of code you can uncomment at the bottom of `ImageCacheManager.init` in order to use an empty image cache on startup.

Requirements
---
- Load a large set of images from a 3rd party service (Flickr) in this case
- Persist data using a database technology (I chose Realm)
- Display images in a layout of my choice (here just a basic grid layout)
- Smooth scrolling! Even during loading and network requests.

3rd Party Libraries
---
### [Realm](https://realm.io/docs/swift/latest/)
I've never used Realm before, but I've done a bunch of reading about it. This was a good opportunity to give it a shot. In general, I recommend rolling your own data layer when using Swift, since libraries like Realm and Core Data require you to subclass a base managed object class, which means you get no immutability or value semantics. A big part of the benefit of Swift is keeping your data objects as `struct`s. In other projects I've created `Repository` classes for interacting with the database, and then the repository vends structs, and updating is the responsibility of the client. (Each view needs to subscribe to certain signals or notifications if they want to remain updated.)

### [Alamofire](https://github.com/Alamofire/Alamofire)
This is kind of the go-to library for doing network requests. It's actually a pretty small wrapper on top of iOS's `URLSession` APIs and provides a very nice interface. I've used some of the ["advanced" ideas](https://github.com/Alamofire/Alamofire#api-parameter-abstraction) from the project's README so that I don't have to pass `NSURL`s around -- instead I can use `enum`s, another one of Swift's awesome features.

### [FastImageCache](https://github.com/path/FastImageCache)
I've used this before in the TribeHR app. It's a very nice combination of on-disk cache (so that images are cached across app launches) and in-memory cache (for performance). FIC uses a single memory-mapped file, not unlike [CSS sprites](https://css-tricks.com/css-sprites/), instead of storing images in separate files. It also does any necessary processing before caching the image. The intention here being that your UI reads images from the cache that are already perfectly sized for the interface. This helps avoid extra work for the GPU at draw-time.

Architecture (Or, where to find stuff)
---

The app follows an MVC-like architecture. I'm greatly enamoured with the [MVVC pattern](https://en.wikipedia.org/wiki/Model–view–viewmodel) (which I've used before in the TribeHR app), but it wasn't a good fit for such a small, single-screen example app.

- The centre of the app is `ImageCollectionViewController`, which manages displaying images ot the user in a grid. It's the central point of interaction for all the other components.
- Naturally, a little bit of setup is done in `AppDelegate`. The image cache is set up here, since it wouldn't be appropriate for the view controller to be responsible for standing up the cache.
- `ImageCacheManager` is where the image caching is handled. It sets up the FastImageCache stack on initialization and acts as FIC's delegate object, handling requests from FIC for the source image and managing in-flight image download requests. (FIC itself doesn't know how to do network requests, so when it asks for an image, this class asks `PhotoManager` to download it for us.)

    For the purposes of this demo, the cache is intentially set up with a limit of 250 items, which is smaller than the data set being presented to the user.
- `PhotoManager` is the centre of the data layer. It manages fetching data from Flickr and adding it to the Realm database.
- `FlickrPhoto` is the data model class representing a single photo on Flickr. It includes all the data returned from Flickr's API and is responsible for generating appropriate URLs to download the image itself (or thumbnail).  
   
    As the object representing an image, `FlickrPhoto` implements the `FICEntity` protocol provided by FastImageCache. This includes stuff that makes sense for this protocol, such as providing UUIDs and URLs so that FIC can decide whether it has a cached version of the image, but it also includes `drawingBlockForImage(_:withFormatName:)`, which provides the code for transforming the image as returned from Flickr into the image to be cached. (Any resizing, cropping, or any other effects you want to include.)  I don't fully agree with the idea of putting this in the data model class, but that's a requirement of using FIC.
- `Router` is an `enum` representing the various calls we can make to the Flickr API. This is useful in formalizing `PhotoManager`'s API and responsibilities.
- `ImageCell` is the last class I haven't mentioned. It's the little piece of UI at the collection view uses to display the Flickr photos!

Shortcomings
---
Since this was just a quick project, there are some shortcomings I want to acknowledge.

### Profiling
I didn't have time to run this through the profiler, but I did run it on some real hardware (an iPhone 5s) and it scrolled actually much smoother than I was expecting, so within the limited time constraints, I'm calling this a win.

### Error Handling
There is none. The code is littered with `//TODO`. Obviously something built to actually ship would need a good approach to letting the user know when something's gone wrong, and what it means to them. (Eg, we might want an error view, and we'd definitely want an "empty" view which should be shown if no images were loaded.)

### Massive View Controller
The collection view controller actually isn't that big, but the data source and delegate should really be implemented in their own classes instead of an extension on the view controller itself.

### Value Semantics
As mentioned in the section about Realm above, the data layer should really take advantage of immutability guarantees and value semantics that Swift provides us.

### Naming
I've tried to use "photo" when it's specific to "I'm showing the user a photo form Flickr" and "image" when it's something generic like "I'm downloading an image from somewhere", but it's not as clear as it could be.

### Other UI
Some easy-to-imagine next steps would be prompting the user to search for the Flickr user whose photos they want to see, and a full-screen image viewer that would be shown when the user taps on an image. I considered these items out of scope.