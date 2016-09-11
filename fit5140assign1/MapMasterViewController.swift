//
//  MapMasterViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 2/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// dictionary used to get the uicolor by a given string, and that string refers to the displayed value in the color picker
let colorDic = ["Black(default)":UIColor.blackColor(),
                "Orange":UIColor.orangeColor(),
                "Blue":UIColor.blueColor(),
                "Green":UIColor.greenColor()]

// dictionary used to get the distance double value by the given index of the segment
let radiusDic = [0:0.0,
                 1:50.0,
                 2:250.0,
                 3:1000.0]

// The MapMasterDeleagte defines the mothod used to reload the alternative map view if after user insert or update
protocol MapMasterDelegate {
    func reloadMap(categories:[Category]!)
}

// this view controller is responsible for the map view of all categories
class MapMasterViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MapMasterDelegate{
    
    // the map view inside this UIVC
    @IBOutlet weak var map: MKMapView!
    
    // for convience set a 1km distance
    let regionRadius: CLLocationDistance = 1000
    
    // the location manager for providing location based actions
    let locationManager: CLLocationManager = CLLocationManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init location manager, request authorization, set accuracy
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // init map relavent
        map.delegate = self
        map.userTrackingMode = .Follow
        map.showsUserLocation = true
        
        // let the homepage got self as delegate
        let navi = self.tabBarController?.viewControllers![0] as! UINavigationController
        let homePage = navi.viewControllers[0] as! HomePageTableViewController
        homePage.mapMasterDelegate = self
        reloadMap(homePage.categoryList)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        map.removeOverlays(map.overlays)
        for a in map.annotations
        {
            if a is MKUserLocation { continue }
            let anno = a as! myPinAnnotation
            let c = anno.c
            let r = radiusDic[(c.radius?.integerValue)!]!
            if r != 0{
                let circle = MKCircle(centerCoordinate: CLLocationCoordinate2D(latitude: c.latitude!.doubleValue, longitude: c.longitude!.doubleValue), radius: r)
                
                map.addOverlay(circle)
            }
            
        }
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        print(userLocation.coordinate)
    }
    

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 5.0, regionRadius * 5.0)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func reloadMap(categories:[Category]!) {
        map.removeAnnotations(map.annotations)
        for c in categories {
            let a = myPinAnnotation(c: c)
            a.title = c.title
            a.coordinate = CLLocationCoordinate2D(latitude: c.latitude!.doubleValue, longitude: c.longitude!.doubleValue)
            map.addAnnotation(a)
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
        
        let myanno = annotation as! myPinAnnotation
        // if nil
        if a == nil{
            // then create.
            a = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            // can be call out
            a!.canShowCallout = true
            
            // set btn
            let btnSet = UIButton(type: .DetailDisclosure)
            btnSet.setImage(UIImage(named: "checklist_icon"), forState: .Normal)
            // display btn
            a!.rightCalloutAccessoryView = btnSet
            
            a?.tintColor = colorDic[myanno.c.color!]
            
        } else{
            // if we already have
            a!.annotation = annotation
        }
        return a
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let a = view.annotation as! myPinAnnotation
        performSegueWithIdentifier("showReminders", sender: a.c)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let c = overlay as! MKCircle
        let cRender = MKCircleRenderer(circle: c)
        cRender.fillColor = UIColor.redColor()
        cRender.alpha = 0.15
        return cRender
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReminders"{
            let target = segue.destinationViewController as! RemindersTableViewController
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            target.managedObjectContext = managedObjectContext
            let c = sender as! Category
            target.c = c

        }
    }
 

}
