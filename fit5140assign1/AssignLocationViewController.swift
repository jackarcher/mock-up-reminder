//
//  AssignLocationViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 2/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MapKit

// class manage the assign location container.
class AssignLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var srchAddress: UISearchBar!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var segRadius: UISegmentedControl!
    
    // the parent view controller delegate
    var addCategoryDelegate:AddCategoryDelegate?
    
    // search result for given address, coulde be []
    var srchResult:[MKPlacemark]! = []
    
    // the location manager for location-based
    let locationManager: CLLocationManager  = CLLocationManager()
    
    // the location set by user (for update use), if the user enable the locaiton based service
    var updateLocation: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // initialize the 2 delegates, programmly
        srchAddress.delegate = self
        map.delegate = self
        
        // set up map
        map.showsUserLocation = false
        
        // set up location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateLocation = addCategoryDelegate?.getLoacation()
        if updateLocation != nil && updateLocation!.coordinate.latitude != 0 {
            map.addAnnotation(updateLocation!)
            map.setRegion(MKCoordinateRegionMakeWithDistance(updateLocation!.coordinate, 5000.0, 5000.0), animated: true)
        }
        
        map.removeOverlays(map.overlays)
        for a in map.annotations
        {
            if a is MKUserLocation { continue }

            let r = radiusDic[(addCategoryDelegate?.getRadius())!]!
            if r != 0{
                let circle = MKCircle(centerCoordinate: a.coordinate, radius: r)
                map.addOverlay(circle)
            }
            
        }
        segRadius.selectedSegmentIndex = (addCategoryDelegate?.getRadius())!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
        search(searchBar.text)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let c = overlay as! MKCircle
        let cRender = MKCircleRenderer(circle: c)
        cRender.fillColor = UIColor.redColor()
        cRender.alpha = 0.15
        return cRender
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // customized annotation view

        // for current location do nothing
        if (annotation is MKUserLocation){
            return nil
        }
        
        //set identifier
        let identifier = "Annotation"
        var a = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        // if nil
        if a == nil{
            // then create.
            a = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            // can be call out
            a!.canShowCallout = true
            
            // set btn
            let btnSet = UIButton(type: .DetailDisclosure)
            btnSet.setImage(UIImage(named: "setLocation_icon"), forState: .Normal)
            // display btn
            a!.rightCalloutAccessoryView = btnSet
        } else{
            // if we already have
            a!.annotation = annotation
        }
        return a
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(view.annotation?.title)

        let alert = UIAlertController(title: "Info", message: "Set this location for category?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Set", style: .Default, handler: {(alert: UIAlertAction!) in
            self.addCategoryDelegate?.setLocation(view.annotation!.coordinate)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    // this method(function) is to finishing a searche, by using the given address
    func search(address: String!){
        // search based one address
        let c = CLGeocoder()
        c.geocodeAddressString(address, completionHandler: {(placemarks,error) -> Void in
            // no result
            if error != nil{
                print(error)
                let alert = UIAlertController(title: "Search Fail", message: "No result found, pleas enhance the searching address", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            // result found
            else {
                print("location search result: \(placemarks?.count)")
                // clear the annotations
                self.map.removeAnnotations(self.srchResult)
                // back up to class level local variable
                self.srchResult = []
                // add to map annotation
                for clp in placemarks!{
                    let mkp = MKPlacemark(placemark: clp)
                    self.map.addAnnotation(mkp)
                    self.srchResult.append(mkp)
                }
                // move screen center
                self.map.setRegion(MKCoordinateRegionMakeWithDistance((self.srchResult!.first?.coordinate)!, 5000.0, 5000.0), animated: true)
            }
        })
    }

    // when people change the radius
    @IBAction func segRadiusValueChanged(sender: UISegmentedControl) {
        addCategoryDelegate?.setRadius(self.segRadius.selectedSegmentIndex) 
    }

}
