//
//  HomePageTableViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 1/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData
import MapKit//?

class HomePageTableViewController: UITableViewController ,HomePageDelegate {

    // core data need this
    var managedObjectContext: NSManagedObjectContext
    
    // the array stored the categories list
    var categoryList: [Category]!
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        self.categoryList = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // enable edit button
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem())
        // core data stuffs
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Category", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entityDescription
        
        var result = NSArray?()
        do {
            result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            print(result!.count)
            if result!.count != 0{
                for r in result! {
                    let c = r as! Category
                    categoryList.append(c)
                }
            }
        } catch{
            let fetchError = error as NSError
            print(fetchError)
        }
        
        // hide footer, it's just ugly I thought
        tableView.tableFooterView = UIView()
        
        // allow for edit!
        tableView.allowsSelectionDuringEditing = true
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
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
        return categoryList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)

        // Configure the cell...

        cell.textLabel?.text = self.categoryList[indexPath.row].title
        switch categoryList[indexPath.row].color! {
        case "Black(default)" :
            cell.textLabel?.textColor = UIColor.blackColor()
            break
        case "Orange" :
            cell.textLabel?.textColor = UIColor.orangeColor()
            break
        case "Blue" :
            cell.textLabel?.textColor = UIColor.blueColor()
            break
        case "Green" :
            cell.textLabel?.textColor = UIColor.greenColor()
            break
        default:
            cell.textLabel?.textColor = UIColor.blueColor()
            break
        }
        return cell
    }
 

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing{
            // to edit page
            performSegueWithIdentifier("categoryDetail", sender: indexPath)
        } else {
            // to reminder page
            performSegueWithIdentifier("showReminders", sender: indexPath)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source and db
            managedObjectContext.deleteObject(categoryList.removeAtIndex(indexPath.row))
            // Delete thr row from view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Commit the change to db
            do{
                try self.managedObjectContext.save()
                print("Delete committed")
            } catch let error{
                print("Save Error while Delete: \n\(error)")
            }
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        //swap 2 element
        let temp = categoryList[fromIndexPath.row]
        categoryList[fromIndexPath.row] = categoryList[toIndexPath.row]
        categoryList[toIndexPath.row] = temp
        
        // commit to db
        
        // print to cmd
        for c in categoryList{
            print(c.title)
        }
        print("***")
    }
 

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
 

    func addCategory(c:Category) {
        // add to the array
        categoryList.append(c)
        // add to db
        self.managedObjectContext.insertObject(c)
        do{
            try self.managedObjectContext.save()
            print("Insert commited")
        } catch let error{
            print("Save Error while Insert: \n\(error)")
        }
        tableView.reloadData()
    }
    
    func refreshUpdate() {
        do{
            try self.managedObjectContext.save()
            print("Update commited")
        } catch let error{
            print("Save Error while Insert: \n\(error)")
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showReminders"{
            let target = segue.destinationViewController as! RemindersTableViewController
            let indexPath = sender as! NSIndexPath
            target.managedObjectContext = self.managedObjectContext
            target.c = categoryList[indexPath.row]
        } else if segue.identifier == "categoryDetail"{
            let navi = segue.destinationViewController as! UINavigationController
            let target = navi.viewControllers[0] as! AddCategoryViewController
            target.homePageDelegate = self
            target.managedObjectContext = self.managedObjectContext
            // todo
            if sender is NSIndexPath{
                // editing
                let indexPath = sender as! NSIndexPath
                target.c = categoryList[indexPath.row]
                target.isEditCategory = true
            } else if sender is UIBarButtonItem{
                // add new
                target.c = nil
                target.isEditCategory = false
            }
        }
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