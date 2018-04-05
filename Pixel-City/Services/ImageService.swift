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
    
    let mapVC = MapVC()
   
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    func retriveUrls(forAnnotation annotation : DroppablePin , completion : @escaping CompletionHandler){
        imageUrlArray.removeAll()
        
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
    
    func retrieveImages(completion : @escaping CompletionHandler){
        imageArray.removeAll()
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                if response.result.error == nil {
                    guard let dataImage = response.result.value else { return }
                    
                    self.imageArray.append(dataImage)
                    
                    NotificationCenter.default.post(name: NOTIF_COUNT_IMAGESDOWNLOADED, object: nil)
                   
                    if self.imageArray.count == self.imageUrlArray.count {
                        completion(true)
                    }
                }else {
                    completion(false)
                    debugPrint(response.result.error as Any)
                }
            }
        }
    }
    
    func cancelAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
