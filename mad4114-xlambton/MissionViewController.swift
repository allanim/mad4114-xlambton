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
import MessageUI

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
    
    @IBAction func btnIPhoto(_ sender: Any) {
        showPhotoAction()
    }
    
    @IBAction func btnRPhoto(_ sender: Any) {
        showPhotoAction()
    }
    
    @IBAction func btnPPhoto(_ sender: Any) {
        showPhotoAction()
    }
    
    @IBAction func btnIEmail(_ sender: Any) {
        sendEmail(nil)
    }
    
    @IBAction func btnRemail(_ sender: Any) {
        sendEmail(nil)
    }
    
    @IBAction func btnPEmail(_ sender: Any) {
        sendEmail(nil)
    }

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

extension MissionViewController: MFMailComposeViewControllerDelegate {
    func sendEmail(_ imageData: Data?) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["you@yoursite.com"])
            mail.setSubject("Hey, Check This Mission")
            mail.setMessageBody("You're so awesome!", isHTML: true)
            
            // add image
            if let fileData = imageData {
                mail.addAttachmentData(fileData, mimeType: "image/jpeg", fileName: "mission.jpeg")
            }
            
            self.present(mail, animated: true)
        } else {
            print("can not send email")
            let alert = UIAlertController(title: nil, message: "Can not send email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension MissionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPhotoAction() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true)
    }
    
    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true)
        }
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageData = image.jpegData(compressionQuality: 0.75)
            self.dismiss(animated: true, completion: { () -> Void in
                self.sendEmail(imageData)
            })
        }else{
            print("Something went wrong")
            self.dismiss(animated: true)
        }
        
    }
    
}
