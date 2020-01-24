//
//  ViewController.swift
//  GoogleMapsIntegration
//
//  Created by R Shantha Kumar on 1/23/20.
//  Copyright © 2020 R Shantha Kumar. All rights reserved.
//

import UIKit
import GoogleMaps
import  GooglePlaces
import Alamofire
import SwiftyJSON

class ViewController: UIViewController,UITextFieldDelegate,GMSAutocompleteViewControllerDelegate{
    
    

    @IBOutlet weak var sourcePLace: UITextField!
    
    @IBOutlet weak var destinationPlace: UITextField!
    
    @IBOutlet weak var mapView22: GMSMapView!
    
    var selectedTF = ""
    var autoCompleteViewCon = GMSAutocompleteViewController()
    
    
    var sourceLocation = CLLocation()
    var destinationLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        sourcePLace.delegate = self
        destinationPlace.delegate = self
        autoCompleteViewCon.delegate = self
        
        
        
        loadMap()
        
        // Do any additional setup after loading the view.
    }
    
// textField delegates
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == sourcePLace){
            
            selectedTF = "source"
            
            present(autoCompleteViewCon, animated: true, completion: nil)
            
        }else if(textField == destinationPlace){
            
            selectedTF = "destination"
            
            present(autoCompleteViewCon, animated: true, completion: nil)
            
        }
    }
    
    
    
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("selection completed")
        
      if(selectedTF == "source")
      {
        
        sourcePLace.text = place.name
        
        sourceLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
    }
    else if (selectedTF == "destination")
      {
        
        destinationPlace.text = place.name
        destinationLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
    }
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("failed")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("cancelled")
    }
    
    
    
    
   
    
    

    func loadMap(){
        
        let camera3 = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
           let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera3)
           mapView22.camera = camera3

           // Creates a marker in the center of the map.
           let marker = GMSMarker()
           marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
           marker.title = "Sydney"
           marker.snippet = "Australia"
           marker.map = mapView22
        
    }
    
    
    @IBAction func getDirection(_ sender: Any) {
        draaPathth(startLocation: sourceLocation, endLocation: destinationLocation)
    }
    
    
    func draaPathth(startLocation:CLLocation,endLocation:CLLocation){
    
        mapView22.clear()
        
        let startMarker1 = GMSMarker()
        startMarker1.position = CLLocationCoordinate2DMake(startLocation.coordinate.latitude, startLocation.coordinate.longitude)
        startMarker1.title = sourcePLace.text!
        startMarker1.snippet = sourcePLace.text!
        startMarker1.map = mapView22
        
        let endMarker = GMSMarker()
        endMarker.position = CLLocationCoordinate2DMake(endLocation.coordinate.latitude, endLocation.coordinate.longitude)
        endMarker.title = destinationPlace.text!
        endMarker.snippet = destinationPlace.text!
        endMarker.map = mapView22
        
        
        let startPointCOrdinates = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        
        let endPointLocation = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        let cordinateURL =  "https://maps.googleapis.com/maps/api/directions/json?origin=\(startPointCOrdinates)&destination=\(endPointLocation)&mode=driving&key=AIzaSyDuBvXGuYzrnh51qC3brdG0OQCsXFHCNLU"
    
        
//     alamofire request
        
    
        Alamofire.request(cordinateURL).responseJSON { (response) in
            
            do{
            
            let jsonData = try JSON(data: response.data!)
                
                
                let routeArray = jsonData["routes"].arrayValue
               
                for i in routeArray{
                    
                    let overViewPolylineDictonary = i["overview_polyline"].dictionary
                    let  points = overViewPolylineDictonary?["points"]?.stringValue
                    let path = GMSPath.init(fromEncodedPath: points!)
                    
                    let polyLine = GMSPolyline.init(path: path)
                    
                    polyLine.strokeWidth = 4
                    polyLine.strokeColor = .systemBlue
                    polyLine.map = self.mapView22
                }
                
                let cameraPosition = GMSCameraPosition.camera(withLatitude: self.sourceLocation.coordinate.latitude, longitude: self.sourceLocation.coordinate.longitude, zoom: 5.0)
                
                self.mapView22.camera = cameraPosition
            }
            catch{
                print("location nor working")
            }
        }
        
        
    
    }
    
    
    
}

