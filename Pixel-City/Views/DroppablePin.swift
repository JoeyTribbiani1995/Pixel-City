//
//  DroppablePin.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/4/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin : NSObject , MKAnnotation {
    dynamic var coordinate : CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate : CLLocationCoordinate2D , identifier : String){
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
