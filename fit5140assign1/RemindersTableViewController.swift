//
//  RemindersTableViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 8/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData

class RemindersTableViewController: UITableViewController {

    var reminderList: NSMutableArray = NSMutableArray()
    
    var managedObjectContext: NSManagedObjectContext?
    
    var c:Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.reminderList = NSMutableArray(array: (c?.from_re?.allObjects)!)
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItems?.append(self.editButtonItem())
        tableView.tableFooterView = UIView()
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
        if r.isDone {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
            let navi = segue.destinationViewController as! UINavigationController
            let target = navi.viewControllers[0] //todo as! and..
            
        }
    }

}
