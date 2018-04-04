//
//  ImageService.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/4/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON


class ImageService {
    
    static let instance = ImageService()
   
    var imageUrlArray = [String]()
    
    func retriveUrls(forAnnotation annotation : DroppablePin , completion : @escaping CompletionHandler){
        ImageService.instance.imageUrlArray = []
        
        Alamofire.request(flickUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            if response.result.error == nil {
               
                guard let data = response.data else { return }
                
                let json = try! JSON(data: data)
                
                let photos = json["photos"].dictionaryValue
                for photo in (photos["photo"]?.arrayValue)! {
                    let postUrl = "https://farm\(photo["farm"]).staticflickr.com/\(photo["server"])/\(photo["id"])_\(photo["secret"])_h_d.jpg"
                    self.imageUrlArray.append(postUrl)
                }
                completion(true)
            }else {
                completion(false)
                debugPrint(response.result.error as Any)
            }
        }
    }
    
}
