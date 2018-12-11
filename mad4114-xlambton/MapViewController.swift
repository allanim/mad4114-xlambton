//
//  MapViewController.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-10.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var iImageView: UIImageView!
    @IBOutlet weak var rImageView: UIImageView!
    @IBOutlet weak var pImageView: UIImageView!
    
    @IBOutlet weak var iSlider: UISlider!
    @IBOutlet weak var rSlider: UISlider!
    @IBOutlet weak var pSlider: UISlider!
    
    @IBOutlet weak var iLabel: UILabel!
    @IBOutlet weak var rLabel: UILabel!
    @IBOutlet weak var pLabel: UILabel!
    
    var mapManager = CLLocationManager()
    var annotations : [MKPointAnnotation] = []
    
    var context: NSManagedObjectContext {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func fetch() -> [AgentEntity] {
        return try! context.fetch(AgentEntity.fetchRequest())
    }
    
    var iDataArray: [AgentEntity] {
        return self.fetch()
            .filter({$0.mission == Missiontype.I.rawValue})
            .sorted(by: { $0.name! < $1.name! })
    }
    
    var rDataArray: [AgentEntity] {
        return self.fetch()
            .filter({$0.mission == Missiontype.R.rawValue})
            .sorted(by: { $0.name! < $1.name! })
    }
    
    var pDataArray: [AgentEntity] {
        return self.fetch()
            .filter({$0.mission == Missiontype.P.rawValue})
            .sorted(by: { $0.name! < $1.name! })
    }
    
    func fetchCountries() -> [CountryEntity] {
        return try! context.fetch(CountryEntity.fetchRequest())
    }
    
    var countries: [CountryEntity] {
        return self.fetchCountries().sorted(by: { $0.name! < $1.name! })
    }
    
    func getCountry(code: String) -> CountryEntity? {
        for country in countries {
            if country.code == code {
                return country
            }
        }
        return nil
    }
    
    var selectedIAgent: AgentEntity?
    var selectedRAgent: AgentEntity?
    var selectedPAgent: AgentEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Location Manager
        mapManager.delegate = self                            // ViewController is the "owner" of the map.
        mapManager.desiredAccuracy = kCLLocationAccuracyBest  // Define the best location possible to be used in app.
        mapManager.requestWhenInUseAuthorization()            // The feature will not run in background
        mapManager.startUpdatingLocation()                    // Continuously geo-position update
        
        // Map View
        mapView.delegate = self
        
        // first map point
        if iDataArray.count > 0 {
            selectedIAgent = iDataArray[0]
        }
        if rDataArray.count > 0 {
            selectedRAgent = rDataArray[0]
        }
        if pDataArray.count > 0 {
            selectedPAgent = pDataArray[0]
        }
        
        // load map point
        reloadAllMission()
        
        // init images
        self.iSlider.minimumValue = 0.0
        self.iSlider.maximumValue = Float(iDataArray.count)
        self.iSlider.value = 0.0
        self.iSlider.thumbTintColor = UIColor.blue
        
        self.rSlider.minimumValue = 0.0
        self.rSlider.maximumValue = Float(rDataArray.count)
        self.rSlider.value = 0.0
        self.rSlider.thumbTintColor = UIColor.green
        
        self.pSlider.minimumValue = 0.0
        self.pSlider.maximumValue = Float(pDataArray.count)
        self.pSlider.value = 0.0
        self.pSlider.thumbTintColor = UIColor.red
        
    }
    
    func reloadAllMission() {
        reloadIMission()
        reloadRMission()
        reloadPMission()
    }
    
    func reloadIMission() {
        if let agent = self.selectedIAgent {
            self.makeMapPoint(agent: agent)
            self.reloadImage(iImageView, code: agent.country!)
            self.iLabel.text = "I: \(agent.country ?? "")"
        }
    }
    func reloadRMission() {
        if let agent = self.selectedRAgent {
            self.makeMapPoint(agent: agent)
            self.reloadImage(rImageView, code: agent.country!)
            self.rLabel.text = "R: \(agent.country ?? "")"
        }
    }
    func reloadPMission() {
        if let agent = self.selectedPAgent {
            self.makeMapPoint(agent: agent)
            self.reloadImage(pImageView, code: agent.country!)
            self.pLabel.text = "P: \(agent.country ?? "")"
        }
    }
    
    func makeMapPoint(agent: AgentEntity) {
        if let country = self.getCountry(code: agent.country!) {
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(country.latitude, country.longitude)
            pointAnnotation.title = agent.mission
            mapView.addAnnotation(pointAnnotation)
            annotations.append(pointAnnotation)
        }
        
    }
    
    func reloadImage(_ imageView: UIImageView, code: String) {
        if let url = StoreUtils.countryImage(code) {
            // creating the background thread
            DispatchQueue.global(qos: DispatchQoS.userInitiated.qosClass).async {
                // Image Download
                let fetch = NSData(contentsOf: url as URL)
                
                //Creating the main thread, that will update the user interface
                DispatchQueue.main.async {
                    
                    // Assign image dowloaded to image variable
                    if let imageData = fetch {
                        imageView.image = UIImage(data: imageData as Data)
                    }
                    
                    // stops the download indicator
//                    self.activity.stopAnimating()
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnMsg(_ sender: Any) {
        performSegue(withIdentifier: "mission", sender: self)
    }
    
    @IBAction func iSliderValueChanged(_ sender: UISlider) {
        self.selectedIAgent = iDataArray[Int(iSlider.value)]
        reloadIMission()
    }
    @IBAction func rSliderValueChanged(_ sender: UISlider) {
        self.selectedRAgent = rDataArray[Int(rSlider.value)]
        reloadRMission()
    }
    @IBAction func pSliderValueChanged(_ sender: UISlider) {
        self.selectedPAgent = pDataArray[Int(pSlider.value)]
        reloadPMission()
    }
}

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // The array locations stores all the user's positions, and the position 0 is the most recent one
        let location = locations[0]
        
        // Here we define the map's zoom. The value 0.01 is a pattern
        let zoom: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 180)
        
        // Store latitude and longitude received from smartphone
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        // Based on myLocation and zoom define the region to be shown on the screen
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: zoom)
        
        // Setting the map itself based previous set-up
        mapView.setRegion(region, animated: true)
        
        // Showing the blue dot in a map
        mapView.showsUserLocation = true
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation.title == Missiontype.I.rawValue
            || annotation.title == Missiontype.R.rawValue
            || annotation.title == Missiontype.P.rawValue {
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "myAnnotation") as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotation")
                //color
                annotationView?.pinTintColor = UIColor.blue
                if annotation.title == Missiontype.R.rawValue {
                    annotationView?.pinTintColor = UIColor.green
                } else if annotation.title == Missiontype.P.rawValue {
                    annotationView?.pinTintColor = UIColor.red
                } else if annotation.title == Missiontype.I.rawValue {
                    annotationView?.pinTintColor = UIColor.blue
                }
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }
}
