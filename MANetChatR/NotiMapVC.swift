import UIKit
import FirebaseDatabase
import GeoFire
import AudioToolbox
import AVFoundation

class NotiMapVC: UIViewController,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noInternetConnectionView: UIView!
    
    var victims = [Victim]()
    
    var audioPlayer:AVAudioPlayer!
    let audioFilePath = Bundle.main.path(forResource: "POP6", ofType: "WAV")
    
    var geoFireRedNoti: GeoFire!
    var geoFireGreenNoti: GeoFire!
    var geoFireVictims: GeoFire!
    
    var geoFireRedNotiRef: FIRDatabaseReference!
    var geoFireGreenNotiRef: FIRDatabaseReference!
    var geoFireVictimsRef: FIRDatabaseReference!
    
    var radiusRefNoti: FIRDatabaseReference!
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var reachability : Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geoFireRedNotiRef = FIRDatabase.database().reference().child("geoFire/red")
        geoFireGreenNotiRef = FIRDatabase.database().reference().child("geoFire/green")
        geoFireVictimsRef = FIRDatabase.database().reference().child("geoFire/victims")
        //        radiusRefNoti = FIRDatabase.database().reference()
        
        geoFireRedNoti = GeoFire(firebaseRef: geoFireRedNotiRef)
        geoFireGreenNoti = GeoFire(firebaseRef: geoFireGreenNotiRef)
        geoFireVictims = GeoFire(firebaseRef: geoFireVictimsRef)
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        fetchVictimsToArray()
        
        do {
            try reachability = Reachability()
        } catch let error as NSError {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (reachability?.isReachable)! {
            noInternetConnectionView.isHidden = true
            self.tabBarController?.tabBar.items?.first?.badgeValue = nil
        } else {
            noInternetConnectionView.isHidden = false
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return victims.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VictimViewCell", for: indexPath) as! VictimViewCell
        cell.nameLabel.text = "\(victims[indexPath.row].name)"
        cell.contentView.alpha = 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: loc)
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
                //                print("Found Green Pin : \(key)")
            }
        })
    }
    
    // Called when annotation is added to mapView.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoIdentifier = "Pokemon"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            //            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            //            annotationView?.image = UIImage(named: "ash")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
            
        } else {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            annoView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = annoView
        }
        
        if let annotationView = annotationView, let anno = annotation as? PinAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pinType)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PinAnnotation {
            
            var place: MKPlacemark!
            if #available(iOS 10.0, *) {
                place = MKPlacemark(coordinate: anno.coordinate)
            } else {
                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            }
            
            let destination = MKMapItem(placemark: place)
            destination.name = "\(anno.title!)"
            
            let regionDistance: CLLocationDistance = 1000
            let region = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: region.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    @IBAction func userLogoTapped(_ sender: Any) {
        let userLocation = locationManager.location
        centerMapOnLocation(location: userLocation!)
    }
    
    func fetchVictimsToArray(){
        geoFireVictimsRef.observe(.value, with: { (snapshot) in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            self.tabBarController?.tabBar.items?.first?.badgeValue = " "
            self.showMessage(title: "Warning", message: "Victim Updated")
            if self.audioFilePath != nil {
                let audioFileUrl = NSURL.fileURL(withPath: self.audioFilePath!)
                do {
                    try self.audioPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                } catch {
                    print("Error")
                }
                self.audioPlayer.play()
            } else {
                print("audio file is not found")
            }

            self.victims.removeAll()
            if let data = snapshot.value as? Dictionary<String,AnyObject>{
                for (key,data) in data {
                    let victimName = key
                    if let location = data["l"] as? Array<Double> {
                        print(location)
                        let coordinate = CLLocation(latitude: location[0], longitude: location[1])
                        self.victims.append(Victim(name: victimName, location: coordinate))
                    }
                }
            }
            self.reloadSightingOnCurrentMapDisplay()
            self.tableView.reloadData()
        })
    }
    
    @IBAction func findVictimButtonTapped(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to:self.tableView)
        let buttonIP = self.tableView.indexPathForRow(at: buttonPosition)
        centerMapOnLocation(location: victims[buttonIP!.row].location)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteVictims = geoFireVictimsRef.child(victims[indexPath.row].name)
            deleteVictims.removeValue()
            victims.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func reloadSightingOnCurrentMapDisplay(){
        let latitude =  mapView.region.center.latitude
        let longtitude = mapView.region.center.longitude
        let location = CLLocation(latitude: latitude, longitude: longtitude)
        showSightingsOnMap(location: location)
    }
    
    func showMessage(title:String , message:String) -> Void {
        let messageWindows = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "done", style: .cancel, handler: nil)
        messageWindows.addAction(action)
        self.present(messageWindows, animated: true, completion: nil)
    }
}
