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
import CoreLocation

class ImageService {
    
    static let instance = ImageService()
    var imageUrlArray = [String]()
    var touchPoint : CLLocationCoordinate2D?
    var titleImage : String?
    var urlImage : String?
    var objectImages = [ObjectImage]()
    var objectImageSelected : ObjectImage?
    
    func retriveUrls(forAnnotation annotation : DroppablePin , completion : @escaping CompletionHandler){
        imageUrlArray.removeAll()
       
        
        Alamofire.request(flickUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            if response.result.error == nil {
               
                guard let data = response.data else { return }
                
                let json = try! JSON(data: data)
                
                let photos = json["photos"].dictionaryValue
                for photo in (photos["photo"]?.arrayValue)! {
                    print(photo)
                    let postUrl = "[https://farm\(photo["farm"]).staticflickr.com/\(photo["server"])/\(photo["id"])_\(photo["secret"])_h_d.jpg,\(photo["title"]),]"
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
        objectImages.removeAll()
        
        for url in imageUrlArray {
            getImage(components: url)
            let title = self.titleImage
            Alamofire.request(self.urlImage!).responseImage { (response) in
                if response.result.error == nil {
                    guard let dataImage = response.result.value else { return }
                    
                    let imageTemp = ObjectImage(title: title, image: dataImage)
                    self.objectImages.append(imageTemp)
                    
                    NotificationCenter.default.post(name: NOTIF_COUNT_IMAGESDOWNLOADED, object: nil)
                   
                    if self.objectImages.count == self.imageUrlArray.count {
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
    
    func getImage(components : String){
        let scanner = Scanner(string: components)

        let skipped = CharacterSet(charactersIn: "[],")
        let comma = CharacterSet(charactersIn: ",")
        scanner.charactersToBeSkipped = skipped
        var urlTemp : NSString?
        var titleTemp : NSString?

        scanner.scanUpToCharacters(from: comma, into: &urlTemp)
        scanner.scanUpToCharacters(from: comma, into: &titleTemp)
        
        let url : String = String(urlTemp ?? "")
        let title : String = String(titleTemp ?? "")
        
        self.titleImage = title
        self.urlImage = url
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
