//
//  RemindersTableViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 8/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData

class RemindersTableViewController: UITableViewController, RemindersTableViewDelegate {

    var reminderList: NSMutableArray = NSMutableArray()
    
    var managedObjectContext: NSManagedObjectContext?
    
    var c:Category?
    
    var btnEdit:UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reminderList = NSMutableArray(array: (c?.from_re?.allObjects)!)
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItems = []
        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(btnAddPerformed)))
        // edit button
        btnEdit = self.editButtonItem()
        self.navigationItem.rightBarButtonItems?.append(btnEdit)
        
        // table edit selectable
        tableView.allowsSelectionDuringEditing = true
        
        tableView.tableFooterView = UIView()
        sort()
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
                }
            } else {
                tab.selectedIndex = 0
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
