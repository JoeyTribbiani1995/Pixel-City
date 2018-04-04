//
//  MapVC.swift
//  Pixel-City
//
//  Created by Joey Tribbiani on 4/3/18.
//  Copyright © 2018 Dũng Võ. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUPViewHeightconstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadius : Double = 1000
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    
    var screenSize = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        doubleTap()
    }
    
    func doubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self , action: #selector(MapVC.dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
    }
    
    @IBAction func centerMapBtnPressed(_ sender: UIButton) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse  {
            centreMapOnUserLocation()
        }
    }
    
    func animateViewUp(){
        pullUPViewHeightconstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(MapVC.animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    @objc func animateViewDown(){
        pullUPViewHeightconstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2 ) - ((spinner?.frame.width)! / 2 ) , y: 100)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
}

extension MapVC : MKMapViewDelegate {
    
    //custom pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil // userlocation default color blue
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centreMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegin = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0 , regionRadius * 2.0)
        mapView.setRegion(coordinateRegin, animated: true)
    }
    
    @objc func dropPin(sender : UITapGestureRecognizer){
        removePin()
        animateViewUp()
        addSwipe()
        addSpinner()
        
        let touchPoint = sender.location(in: mapView) //get location
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView) //convert gps
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation) // add pin to map view
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin(){
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}


extension MapVC : CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centreMapOnUserLocation()
    }
}




