//
//  AssignLocationViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 2/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MapKit

protocol AddCategoryDelegate {
    func setLocation(location: MKAnnotation)
    func setRadius(r:Int)
}

class AssignLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var srchAddress: UISearchBar!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var segRadius: UISegmentedControl!
    
    var addCategoryDelegate:AddCategoryDelegate?
    
    var srchResult:[MKPlacemark]! = []
    
    
    let locationManager: CLLocationManager  = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // initialize the 3 delegates, programmly
        srchAddress.delegate = self
        map.delegate = self
        
        // set up map
        map.userTrackingMode = .Follow
        map.showsUserLocation = true
        
        // set up location manager
        // todo region
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchBar.text == nil || (searchBar.text?.isEmpty)!{
            let msg = "Please input your message"
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else{
            view.endEditing(true)
            search(searchBar.text)
        }
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
            self.addCategoryDelegate?.setLocation(view.annotation!)
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
                self.map.setCenterCoordinate((self.srchResult!.first?.coordinate)!, animated: true)
            }
        })
    }

    @IBAction func segRadiusValueChanged(sender: UISegmentedControl) {
        addCategoryDelegate?.setRadius(self.segRadius.selectedSegmentIndex)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
