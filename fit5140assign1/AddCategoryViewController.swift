//
//  AddCategoryViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 1/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData
import MapKit

protocol AddCategoryDelegate {
    func setLocation(location: CLLocationCoordinate2D)
    func getLoacation() -> MKAnnotation?
    func setRadius(r:Int)
    func getRadius() -> Int
}

class AddCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, AddCategoryDelegate, UITextFieldDelegate {

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var segSwitch: UISegmentedControl!
    // delegate for homepage(AKA category list)
    var homePageDelegate: HomePageDelegate?
    // for core data
    var managedObjectContext: NSManagedObjectContext!
    // selected color index
    var selectedColour: Int = 0
    // location manager for location-based service
    let locationManager = CLLocationManager()
    // color data source
    let colours = ["Black(default)","Orange","Blue","Green"]
    // location data sorece
    var selectedLocation: MKPointAnnotation?
    // selected notification radius index
    var selectedRadius:Int = 0
    // current category
    var c: Category!
    // indicate if this VC is for editing(True) or for Creating(False)
    var isEditCategory: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        segSwitch.selectedSegmentIndex = 1
        self.container.alpha = 0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var msg: String?
        if !isEditCategory {
            self.c = Category.init(entity: NSEntityDescription.entityForName("Category", inManagedObjectContext: self.managedObjectContext )!,insertIntoManagedObjectContext: self.managedObjectContext)
            msg = "Create"
        } else {
            msg = "Update"
            txtTitle.text = c.title
            let colorDic = ["Black(default)":0,"Orange":1,"Blue":2,"Green":3]
            self.selectedColour = colorDic[self.c.color!]!
            self.colorPicker.selectRow(self.selectedColour, inComponent: 0, animated: true)
            if self.c.latitude == nil {
                segSwitch.selectedSegmentIndex = 1
                self.container.alpha = 0
            } else {
                segSwitch.selectedSegmentIndex = 0
                self.container.alpha = 1
                // todo set annotation for map
                selectedLocation = MKPointAnnotation()
                selectedLocation?.title = c.title
                selectedLocation?.coordinate = CLLocationCoordinate2D(latitude: (c.latitude?.doubleValue)!, longitude: (c.longitude?.doubleValue)!)
                selectedRadius = (c.radius?.integerValue)!

            }
            
        }
        self.navigationItem.rightBarButtonItems = []
        let btnFinish = UIBarButtonItem(title: msg, style: .Done, target: self, action: #selector(btnFinishPerformed(_:)))
        self.navigationItem.title = "\(msg!) Category"
        self.navigationItem.rightBarButtonItems?.append(btnFinish)
        
        txtTitle.delegate = self
        txtTitle.returnKeyType = .Done

    }

    @IBAction func SegSwiched(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // show container
            UIView.animateWithDuration(0.5, animations: {
                self.container.alpha = 1
            })
        } else {
            // hide
            UIView.animateWithDuration(0.5, animations: {
                self.container.alpha = 0
                self.container.endEditing(true)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCancelPerformed(sender: AnyObject) {
        // hide keyboard, make consistency
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func btnFinishPerformed(sender: AnyObject) {
        // validation
        if self.txtTitle.text == nil || (self.txtTitle.text?.isEmpty)!{
            let alert = UIAlertController(title: "Validation fail", message: "Title field is required", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if segSwitch.selectedSegmentIndex == 0 && selectedLocation == nil{
            let alert = UIAlertController(title: "Validation fail", message: "Please set the location by tap the annotaion of selected location", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            view.endEditing(true)
            dismissViewControllerAnimated(true, completion: {
                // send the data back to homepage.
                // my design is to use a delegate.
                self.c.setValue(self.txtTitle.text!, forKey: "title")
                self.c.setValue(self.colours[self.selectedColour], forKey: "color")
                if self.segSwitch.selectedSegmentIndex == 0{
                    let lati = self.selectedLocation?.coordinate.latitude
                    let longi = self.selectedLocation?.coordinate.longitude
                    self.c.setValue(lati, forKey: "latitude")
                    self.c.setValue(longi, forKey: "longitude")
                    self.c.setValue(self.selectedRadius, forKey: "radius")
                } else if self.segSwitch.selectedSegmentIndex == 1 {
                    self.c.setValue(nil, forKey: "latitude")
                    self.c.setValue(nil, forKey: "longitude")
                    self.c.setValue(0, forKey: "radius")
                }
                self.homePageDelegate?.refreshUpdate()
                if !self.isEditCategory{
                    self.homePageDelegate!.addCategory(self.c)
                }
            })
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colours.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colours[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedColour = row
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMAP"{
            let target = segue.destinationViewController as! AssignLocationViewController
            target.addCategoryDelegate = self
        } else if (segue.identifier == "showReminders"){
            let target = segue.destinationViewController as! RemindersTableViewController
            target.reminderList = NSMutableArray(array: (c.from_re?.allObjects)!)
        }
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        print(location)
        if selectedLocation == nil{
            selectedLocation = MKPointAnnotation()
        }
        self.selectedLocation!.coordinate = location
    }
    
    func getLoacation() -> MKAnnotation?{
        return selectedLocation
    }
    
    func setRadius(r: Int) {
        self.selectedRadius = r
    }
    
    func getRadius() -> Int {
        return self.selectedRadius
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

}
