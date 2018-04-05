//
//  PopVC.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/5/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PopVC: UIViewController {
    
    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleImageLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadius : Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PopVC.handleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        if let objectImage = ImageService.instance.objectImageSelected {
            popImageView.image = objectImage.image
            titleImageLbl.text = objectImage.title
        }
        updateLocaitonToMapView()
    }
    
    @objc func handleTap(_ recog : UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
    
    

}

extension PopVC : CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else {
            return
        }
    }
}

extension PopVC : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinAnnoation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "location")
        pinAnnoation.pinTintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        pinAnnoation.animatesDrop = true
        
        return pinAnnoation
    }

    func updateLocaitonToMapView(){
        
        guard let touchPoint = ImageService.instance.touchPoint else { return }
        let annotation = DroppablePin(coordinate: touchPoint, identifier: "locaiton")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchPoint,regionRadius * 2.0 ,regionRadius * 2.0 )
        mapView.setRegion(coordinateRegion, animated: true)
    }
}





