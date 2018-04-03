//
//  MapVC.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/3/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController , MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    
    @IBAction func centerMapBtnPressed(_ sender: UIButton) {
    }
}





