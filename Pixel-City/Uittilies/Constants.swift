//
//  constants.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/4/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import Foundation

let API_KEY = "501658817178249b6b5cef8705b00138"


func flickUrl(forApiKey key : String , withAnnotation annotation : DroppablePin , andNumberOfPhotos number : Int ) -> String {
    
    let BASE_URL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    
    return BASE_URL
}

typealias CompletionHandler = (_ success : Bool ) -> ()
