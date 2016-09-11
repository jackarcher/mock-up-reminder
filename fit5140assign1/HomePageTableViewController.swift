//
//  HomePageTableViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 1/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData
import MapKit

protocol HomePageDelegate {
    func addCategory(c:Category)
    func refreshUpdate()
    func getCatories() -> [Category]!
}

class HomePageTableViewController: UITableViewController ,HomePageDelegate {

    // core data need this
    var managedObjectContext: NSManagedObjectContext
    
    // the array stored the categories list
    var categoryList: [Category]!
    
    // map master delegate
    var mapMasterDelegate:MapMasterDelegate?
    
    
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
                    print("\(c.title!):\(c.order!)")
                }
            }
        } catch{
            let fetchError = error as NSError
            print(fetchError)
        }
        
        categoryList.sortInPlace({
        c1, c2 in
            return Int(c1.order!)<Int(c2.order!)
        })
        
        // hide footer, it's just ugly I thought
        tableView.tableFooterView = UIView()
        
        // allow for edit!
        tableView.allowsSelectionDuringEditing = true
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if mapMasterDelegate != nil{
            mapMasterDelegate!.reloadMap(self.categoryList)
            print("Map Master Page Reload")
        } else {
            print("delegate to be set")
        }
        

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
        cell.textLabel?.text = categoryList[indexPath.row].title
        cell.textLabel?.textColor = colorDic[categoryList[indexPath.row].color!]
        return cell
    }
 

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            
            for i in indexPath.row ..< categoryList.count{
                categoryList[i].setValue(i, forKey: "order")
            }
            performSegueWithIdentifier("afterDeleteCategory", sender: nil)
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
        categoryList.insert(categoryList.removeAtIndex(fromIndexPath.row), atIndex: toIndexPath.row)
        var max:Int
        var min:Int
        if fromIndexPath.row > toIndexPath.row{
            max = fromIndexPath.row
            min = toIndexPath.row
        } else if fromIndexPath.row < toIndexPath.row{
            max = toIndexPath.row
            min = fromIndexPath.row
        } else {
            max = 0
            min = 0
        }
        if max != min {
            for i in min ... max{
                categoryList[i].setValue(i, forKey: "order")
            }
            // commit to db
            do {
                try self.managedObjectContext.save()
            } catch {
                print(error)
            }
            // sort the list
            categoryList.sortInPlace({
                c1, c2 in
                return Int(c1.order!)<Int(c2.order!)
            })
        }
        performSegueWithIdentifier("afterDeleteCategory", sender: nil)
    }
 

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
 

    func addCategory(c:Category) {
        // add to the array
        categoryList.append(c)
        c.setValue(categoryList.indexOf(c), forKey: "order")
        print(c)
        // add to db
        do{
            try self.managedObjectContext.save()
            print("Insert commited")
        } catch let error{
            print("Save Error while Insert: \n\(error)")
        }
        tableView.reloadData()
    }
    
    func refreshUpdate() {
        print(categoryList.first)
        do{
            try self.managedObjectContext.save()
            print("Update commited")
        } catch let error{
            print("Save Error while Insert: \n\(error)")
        }
        tableView.reloadData()
    }
    
    
    func getCatories() -> [Category]!{
        return self.categoryList
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
        } else if segue.identifier == "afterDeleteCategory"{
            let tab = segue.destinationViewController as! UITabBarController
            tab.selectedIndex = 0
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
