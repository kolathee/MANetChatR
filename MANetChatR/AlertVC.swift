//
//  AlertVC.swift
//  MANetChatR
//
//  Created by kolathee on 3/7/2560 BE.
//  Copyright © 2560 kolathee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GeoFire

class AlertVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var valueOfStepperLabel: UILabel!
    @IBOutlet weak var centerPinImage: UIImageView!
    @IBOutlet weak var noInternetConnectionView: UIView!
    
    @IBOutlet weak var sendAlertButton: UIButton!
    var geoFireRedNoti: GeoFire!
    var geoFireGreenNoti: GeoFire!
    var geoFireVictims: GeoFire!
    
    var geoFireRedNotiRef: FIRDatabaseReference!
    var geoFireGreenNotiRef: FIRDatabaseReference!
    var geoFireVictimsRef: FIRDatabaseReference!
    
    var radiusNotiRef: FIRDatabaseReference!
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var reachability:Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.value = 1
        stepper.wraps = true
        stepper.autorepeat = true
        setStapperLabel(km: stepper.value)
        
        geoFireRedNotiRef = FIRDatabase.database().reference().child("geoFire/red")
        geoFireGreenNotiRef = FIRDatabase.database().reference().child("geoFire/green")
        geoFireVictimsRef = FIRDatabase.database().reference().child("geoFire/victims")
        radiusNotiRef = FIRDatabase.database().reference().child("geoFire/radius")
        
        geoFireRedNoti = GeoFire(firebaseRef: geoFireRedNotiRef)
        geoFireGreenNoti = GeoFire(firebaseRef: geoFireGreenNotiRef)
        geoFireVictims = GeoFire(firebaseRef: geoFireVictimsRef)
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        do {
            try reachability = Reachability()
        } catch let error as NSError {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (reachability?.isReachable)! {
            noInternetConnectionView.isHidden = true
            sendAlertButton.isEnabled = true
        } else {
            noInternetConnectionView.isHidden = false
            sendAlertButton.isEnabled = false
        }
        locationAuthStatus()
    }
    
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func showSightingsOnMap(location: CLLocation) {
        
        //Reset(REMOVE ALL) all of annotation on the map.
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let circleQueryRedNoti = geoFireRedNoti!.query(at: location, withRadius: 5)
        let circleQueryGreenNoti = geoFireGreenNoti!.query(at: location, withRadius: 5)
        let circleQueryVictim = geoFireVictims!.query(at: location, withRadius: 5)
        
        //Victim Notification Observer
        _ = circleQueryVictim?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key, let location = location {
                let anno = PinAnnotation(coordinate: location.coordinate, username: key)
                self.mapView.addAnnotation(anno)
                //                print("Found : \(key)")
            }
        })
        
        //Red Pin Notification Observer
        _ = circleQueryRedNoti?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let id = key, let location = location {
                let anno = PinAnnotation(coordinate: location.coordinate, pintype: "red_pin",id:id)
                self.mapView.addAnnotation(anno)
            }
        })
        //Green Pin Notification Observer
        _ = circleQueryGreenNoti?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let id = key, let location = location {
                let anno = PinAnnotation(coordinate: location.coordinate, pintype: "green_pin",id:id)
                self.mapView.addAnnotation(anno)
            }
        })
    }
    
    // Called when annotation is added to mapView.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let anno = annotation as? PinAnnotation
        var annoIdentifier:String
        
        if anno?.pinType != "person_pin" {
            annoIdentifier = "person"
        } else {
            annoIdentifier = "pin"
        }
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            //            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            //            annotationView?.image = UIImage(named: "ash")
            
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
            
        } else {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            annotationView = annoView
        }
        
        if let annotationView = annotationView, let anno = annotation as? PinAnnotation {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pinType)")
            
            if anno.pinType != "person_pin" {
                let btn = UIButton()
                btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                btn.setImage(#imageLiteral(resourceName: "x"), for: .normal)
                annotationView.rightCalloutAccessoryView = btn
            }
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PinAnnotation {
            let alertView = UIAlertController(title: "Do you want to delete it?", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(action:UIAlertAction) in
                self.deletePin(pinType: anno.pinType, id: anno.id!)
            })
            alertView.addAction(cancelAction)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
            //            var place: MKPlacemark!
            //            if #available(iOS 10.0, *) {
            //                place = MKPlacemark(coordinate: anno.coordinate)
            //            } else {
            //                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            //            }
            //
            //            let destination = MKMapItem(placemark: place)
            //            destination.name = "\(anno.title!)"
            //
            //            let regionDistance: CLLocationDistance = 1000
            //            let region = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            //
            //            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: region.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            //
            //            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    @IBAction func userLogoWasTapped(_ sender: Any) {
        let userLocation = locationManager.location
        centerMapOnLocation(location: userLocation!)
    }
    
    @IBAction func greenButtonTapped(_ sender: Any) {
        centerPinImage.image = UIImage(named:"green_pin")
        centerPinImage.restorationIdentifier = "green_pin"
    }
    
    @IBAction func redButtonTapped(_ sender: Any) {
        centerPinImage.image = UIImage(named:"red_pin")
        centerPinImage.restorationIdentifier = "red_pin"
    }
    
    @IBAction func stepperTapped(_ sender: Any) {
        setStapperLabel(km: stepper.value)
    }
    
    @IBAction func sendAlert(_ sender: Any) {
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        if centerPinImage.restorationIdentifier == "green_pin" {
            let path = geoFireGreenNotiRef.childByAutoId()
            print(path)
            print("newKey : \(path.key)")
            geoFireGreenNoti.setLocation(location, forKey: "\(path.key)")
            let dataToRadius = [path.key:stepper.value]
            radiusNotiRef.updateChildValues(dataToRadius)
        } else {
            let path = geoFireRedNotiRef.childByAutoId()
            print(path)
            print("newKey : \(path.key)")
            geoFireRedNoti.setLocation(location, forKey: "\(path.key)")
            let dataToRadius = [path.key:stepper.value]
            radiusNotiRef.updateChildValues(dataToRadius)
        }
    }
    
    func reloadSightingOnCurrentMapDisplay(){
        let latitude =  mapView.region.center.latitude
        let longtitude = mapView.region.center.longitude
        let location = CLLocation(latitude: latitude, longitude: longtitude)
        showSightingsOnMap(location: location)
    }
    
    func setStapperLabel(km:Double) {
        valueOfStepperLabel.text = "Redius : \(Int(km)) km"
    }
    
    func deletePin(pinType:String,id:String){
        
        if pinType == "red_pin"{
            //remove red pin
            let deletePin = self.geoFireRedNotiRef.child(id)
            deletePin.removeValue()
            radiusNotiRef.child(id).removeValue()
        }
        
        if pinType == "green_pin"{
            let deletePin = self.geoFireGreenNotiRef.child(id)
            deletePin.removeValue()
            radiusNotiRef.child(id).removeValue()
        }
        self.reloadSightingOnCurrentMapDisplay()
    }
}
