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
    
    var collectionView : UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        doubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        pullUpView.addSubview(collectionView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapVC.updateProgressLbl(_:)), name: NOTIF_COUNT_IMAGESDOWNLOADED, object: nil)
        
        registerForPreviewing(with: self, sourceView: collectionView!)
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
        
        ImageService.instance.cancelAllSessions()
    }
    
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2 ) - ((spinner?.frame.width)! / 2 ) , y: 100)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2 ) - 120 , y: 50, width: 240, height: 150)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLbl?.textAlignment = .center
        
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl(){
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    
    @objc func updateProgressLbl(_ notifi : Notification){
        progressLbl?.text = "\(ImageService.instance.imageArray.count)/40 images downloaded"
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
        removeSpinner()
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLbl()
        
        ImageService.instance.cancelAllSessions()
        ImageService.instance.imageArray.removeAll()
        ImageService.instance.imageUrlArray.removeAll()
        
        collectionView?.reloadData()
        
        
        
        let touchPoint = sender.location(in: mapView) //get location
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView) //convert gps
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation) // add pin to map view
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        ImageService.instance.retriveUrls(forAnnotation: annotation) { (success) in
            if success {
                print("success  retrive urls -------------")
                print(ImageService.instance.imageUrlArray)
                
                ImageService.instance.retrieveImages { (success) in
                    if success {
                        print("--------success retrieve image ")
                       
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                        
                    }
                }
            }
        }
        
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


extension MapVC : UICollectionViewDelegate , UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageService.instance.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell {
            
            let image = ImageService.instance.imageArray[indexPath.row]
            let imageView = UIImageView(image: image)
            cell.addSubview(imageView)
            
            return cell
        }else {
             return PhotoCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image = ImageService.instance.imageArray[indexPath.row]
        ImageService.instance.imageSelected = image
        
        performSegue(withIdentifier: TO_POPVC , sender: nil)
    }
}

//touch 3d
extension MapVC : UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) , let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        let image = ImageService.instance.imageArray[indexPath.row]
        ImageService.instance.imageSelected = image
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: IDENTIFIER_STORYBOARD_POPVC) as? PopVC else { return nil }
        
        
        previewingContext.sourceRect = cell.contentView.frame
        
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}




