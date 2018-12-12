//
//  MissionViewController.swift
//  mad4114-xlambton
//
//  Created by Allan Im on 2018-12-11.
//  Copyright © 2018 Allan Im. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class MissionViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var lbIDistance: UILabel!
    @IBOutlet weak var lbRDistance: UILabel!
    @IBOutlet weak var lbPDistance: UILabel!
    
    var mapManager = CLLocationManager()
    
    var iAgent: AgentEntity?
    var rAgent: AgentEntity?
    var pAgent: AgentEntity?
    
    var context: NSManagedObjectContext {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Location Manager
        mapManager.delegate = self                            // ViewController is the "owner" of the map.
        mapManager.desiredAccuracy = kCLLocationAccuracyBest  // Define the best location possible to be used in app.
        mapManager.requestWhenInUseAuthorization()            // The feature will not run in background
        mapManager.startUpdatingLocation()                    // Continuously geo-position update
        
        // Map View
        mapView.delegate = self
        
        // make point
        if let agent = iAgent {
            makeMapPoint(agent: agent)
        }
        if let agent = rAgent {
            makeMapPoint(agent: agent)
        }
        if let agent = pAgent {
            makeMapPoint(agent: agent)
        }
        
    }
    
    func makeMapPoint(agent: AgentEntity) {
        if let country = self.getCountry(code: agent.country!) {
            // make annotation
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2DMake(country.latitude, country.longitude)
            pointAnnotation.title = agent.mission
            mapView.addAnnotation(pointAnnotation)
        }
    }
    
    func pickRegion(agent: AgentEntity) {
        if let country = self.getCountry(code: agent.country!) {
            let region = makeRegion(latitude: country.latitude, longitude: country.longitude)
            mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func iAction(_ sender: Any) {
        if let agent = iAgent {
            pickRegion(agent: agent)
        }
    }
    
    @IBAction func rAction(_ sender: Any) {
        if let agent = rAgent {
            pickRegion(agent: agent)
        }
    }
    
    @IBAction func pAction(_ sender: Any) {
        if let agent = pAgent {
            pickRegion(agent: agent)
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

}

extension MissionViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func makeRegion(latitude: Double, longitude: Double) -> MKCoordinateRegion {
        // Here we define the map's zoom. The value 0.01 is a pattern
        let zoom: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 180)
        
        // Store latitude and longitude received from smartphone
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        // Based on myLocation and zoom define the region to be shown on the screen
        return MKCoordinateRegion(center: myLocation, span: zoom)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // The array locations stores all the user's positions, and the position 0 is the most recent one
        let location = locations[0]
        
        // Make Region
        let region = makeRegion(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        // Setting the map itself based previous set-up
        mapView.setRegion(region, animated: true)
        
        // Showing the blue dot in a map
        mapView.showsUserLocation = true
        
        // distance
        if let agent = iAgent {
            if let country = getCountry(code: agent.country!) {
                let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    .distance(from: CLLocation(latitude: country.latitude, longitude: country.longitude))
                self.lbIDistance.text = String(Int((distance / 1000).rounded())) + "Km"
            }
        }
        if let agent = rAgent {
            if let country = getCountry(code: agent.country!) {
                let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    .distance(from: CLLocation(latitude: country.latitude, longitude: country.longitude))
                self.lbRDistance.text = String(Int((distance / 1000).rounded())) + "Km"
            }
        }
        if let agent = pAgent {
            if let country = getCountry(code: agent.country!) {
                let distance = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    .distance(from: CLLocation(latitude: country.latitude, longitude: country.longitude))
                self.lbPDistance.text = String(Int((distance / 1000).rounded())) + "Km"
            }
        }
        
        
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
