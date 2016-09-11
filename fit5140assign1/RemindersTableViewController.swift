//
//  RemindersTableViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 8/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class RemindersTableViewController: UITableViewController, RemindersTableViewDelegate, CLLocationManagerDelegate {

    var reminderList: NSMutableArray = NSMutableArray()
    
    var managedObjectContext: NSManagedObjectContext?
    
    var c:Category?
    
    var btnEdit:UIBarButtonItem!
    
    // refer:http://stackoverflow.com/questions/28959201/create-local-location-based-notifications-in-swift
    let notification = UILocalNotification()
    
    let locationManager = CLLocationManager()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reminderList = NSMutableArray(array: (c?.from_re?.allObjects)!)
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.title = "Reminder List"
        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(btnAddPerformed)))
        // edit button
        btnEdit = self.editButtonItem()
        self.navigationItem.rightBarButtonItems?.append(btnEdit)
        
        // table edit selectable
        tableView.allowsSelectionDuringEditing = true
        
        tableView.tableFooterView = UIView()
        
        if c?.latitude != nil {
            notification.regionTriggersOnce = false
            notification.region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: (c?.latitude!.doubleValue)!, longitude: (c?.longitude?.doubleValue)!), radius: radiusDic[(c?.radius?.integerValue)!]!, identifier: (c?.title)!)
        }

    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if c?.radius?.intValue != 0{
            notification.alertTitle = "Enter location"
            notification.alertBody = "You've entered the location of your reminder"
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduledLocalNotifications?.append(notification)
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        if c?.radius?.intValue != 0{
            notification.alertTitle = "Leave location"
            for r in reminderList {
                let r = r as! Reminder
                if !r.isDone {
                    notification.alertBody = "You've Leave the location of your reminder, without finishing everything"
                    break
                }
            }
        }
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().scheduledLocalNotifications?.append(notification)
    }
    
    override func viewWillAppear(animated: Bool) {
        sort()
        tableView.reloadData()
    }


    func sort(){
        reminderList.sortUsingComparator({
            e1, e2 in
            let r1 = e1 as! Reminder
            let r2 = e2 as! Reminder
            
            if r1.isDone && r2.isDone {
                return NSComparisonResult.OrderedSame
            } else if r1.isDone {
                return NSComparisonResult.OrderedDescending
            } else if r2.isDone {
                return NSComparisonResult.OrderedAscending
            } else {
                // ealier --> negative
                // 2 nil?
                if r1.due == nil && r2.due == nil{
                    return NSComparisonResult.OrderedSame
                } else if r1.due == nil {
                    // only 1 is nil
                    return NSComparisonResult.OrderedDescending
                } else if r2.due == nil {
                    // only 2 is nil
                    return NSComparisonResult.OrderedAscending
                }
                else {
                    // no nil
                    let timeDifferent = r1.due?.timeIntervalSinceDate(r2.due!)
                    if  timeDifferent < 0 { return NSComparisonResult.OrderedAscending}
                    else if timeDifferent > 0 { return NSComparisonResult.OrderedDescending }
                    else { return NSComparisonResult.OrderedSame }
                }
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (reminderList.count)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reminder", forIndexPath: indexPath)
        let r = reminderList[indexPath.row] as! Reminder
        cell.textLabel?.text = r.title
        
        // check completeness
        if r.isDone {
            cell.accessoryType = .Checkmark
            cell.textLabel?.textColor = UIColor.grayColor()
        } else {
            cell.accessoryType = .None
            if r.due != nil && r.due?.compare(NSDate()) == .OrderedAscending{
                // overdue set red
                cell.textLabel?.textColor = UIColor.redColor()
            } else {
                cell.textLabel?.textColor = UIColor.blackColor()
            }
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("reminderDetail", sender: indexPath)
    }


    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            reminderList.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
 

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "reminderDetail"{
            let tab = segue.destinationViewController as! UITabBarController
            let navi = tab.viewControllers![1] as! UINavigationController
            if sender != nil{
                tab.selectedIndex = 1
                let target = navi.viewControllers[0] as! ReminderDetailViewController
                target.remindersTableViewDelegate = self
                if sender is UIBarButtonItem{
                    // add reminder
                    target.r = nil
                    target.isEditReminder = false
                } else if sender is NSIndexPath{
                    // check or update reminder
                    let indexPath = sender as! NSIndexPath
                    target.r = reminderList[indexPath.row] as! Reminder
                    if tableView.editing{
                        target.isEditReminder = true
                    } else {
                        target.isEditReminder = nil
                    }
                } else if (sender as! String) == "popup"{
                        tab.selectedIndex = 0
                }
            }
        }
    }
    
    func btnAddPerformed(){
        performSegueWithIdentifier("reminderDetail", sender: UIBarButtonItem())
    }
    
    func addReminder(r: Reminder) {
        do{
            reminderList.addObject(r)
            sort()
            c?.addFrom_reObject(r)
            try managedObjectContext?.save()
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    
    func udpdateReminder() {
        do{
            sort()
            try managedObjectContext?.save()
            self.tableView.reloadData()
            setEditing(false, animated: true)
        } catch {
            print(error)
        }
    }
    
    func cancelEdit(){
        setEditing(false, animated: true)
    }
    
    func displayHome(){
        self.performSegueWithIdentifier("reminderDetail", sender: nil)
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !editing {
            btnEdit.title = "Edit"
            btnEdit.style = .Plain
        } else {
            btnEdit.title = "Done"
            btnEdit.style = .Done
        }
        
    }
}
