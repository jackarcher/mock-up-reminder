//
//  ReminderDetailViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 8/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData

// the delegate for remindertableview
protocol RemindersTableViewDelegate {
    // add new reminder to the table view and reload UI
    func addReminder(r:Reminder)
    // update coredata and reload UI
    func udpdateReminder()
    // cancel edit if we were in edit mode, to the reminder table view, which is the master
    func cancelEdit()
    // display the place holder page for detail view in splite, to prevent user from interaction concurrently with the master view and the detail veiw in splite
    func displayHome()
}

// to create, or update, or check the reminder detail
class ReminderDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtViewNote: UITextView!
    @IBOutlet weak var segSwitch: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var managedObjectContext:NSManagedObjectContext?
    
    var remindersTableViewDelegate: RemindersTableViewDelegate?
    
    // indicate the situation of this vc
    // true     <==> user is edit an exsiting reminder, interaction to master view disabled in this mode.
    // false    <==> user is createing an new reminder, interaction to master view disabled in this mode.
    // nil      <==> user is check an existing new reminder, interaction to detail view disabled in this mode.
    var isEditReminder:Bool?
    
    // the current reminder
    var r:Reminder!

    // the maste view controller
    var masterVC: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // init core data relevant
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        // date picker
        self.datePicker.datePickerMode = .DateAndTime
        // hide tabbar
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.selectedIndex = 1
        // for portait use, left up corner add button
        self.navigationItem.leftBarButtonItems = []
        self.navigationItem.leftBarButtonItems?.append((splitViewController?.displayModeButtonItem())!)
        // add cancel button to left-top corner
        let btnCancel = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(btnCancelPerformed(_:)))
        self.navigationItem.leftBarButtonItems?.append(btnCancel)
        // txtfield relavent
        txtTitle.delegate = self
        // txtview relavent
        txtViewNote.delegate = self
        // show border
        txtViewNote.layer.borderWidth = 1
        txtViewNote.layer.borderColor = UIColor(red: 213.0/255.0, green: 213.0/255.0, blue: 213.0/255.0, alpha: 1.0).CGColor
        txtViewNote.layer.cornerRadius = 8
        
        datePicker.alpha = 0
        datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        
        // disable masterVC interaction
        
        masterVC = self.splitViewController?.viewControllers.first
        
        masterVC.view.userInteractionEnabled = false
        
        //load UI
        reloadUI()
    }

    // might move some reloadui to here 
    // todo
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // set the ui to refer the current situation of reminder within DB.
    // this method will init for 3 different mode mentioned above
    func reloadUI(){
        // message to show the function of this VC, which indicates the current use of this VC (to check reminder/ to update reminder / to create reminder)
        var msg: String?
        
        if isEditReminder == nil {
            // check the reminder
            if r.isDone {
                msg = "Uncheck"
            } else {
                msg = "Check"
            }
            // set title
            txtTitle.text = r.title
            txtTitle.userInteractionEnabled = false
            // set note
            txtViewNote.text = r.note
            txtViewNote.userInteractionEnabled = false
            // set due switch and datepicker
            if r.due == nil{
                datePicker.date = NSDate()
                segSwitch.setEnabled(false, forSegmentAtIndex: 0)
            } else {
                datePicker.date = r.due!
                segSwitch.setEnabled(false, forSegmentAtIndex: 1)
            }
            datePicker.userInteractionEnabled = false
            
            // set annimation for due and data picker
            UIView.animateWithDuration(0.5, animations: {
                if self.r.due == nil {
                    self.segSwitch.selectedSegmentIndex = 1
                    self.datePicker.alpha = 0
                } else {
                    self.segSwitch.selectedSegmentIndex = 0
                    self.datePicker.alpha = 1
                }
            })
            
            // enable master view userinteraction
            masterVC.view.userInteractionEnabled = true
        }
        else if !isEditReminder! {
            // create new reminder
            r = Reminder(entity: NSEntityDescription.entityForName("Reminder", inManagedObjectContext: self.managedObjectContext!)!, insertIntoManagedObjectContext: self.managedObjectContext!)
            msg = "Create"
            UIView.animateWithDuration(0.5, animations: {
                self.segSwitch.selectedSegmentIndex = 1
                self.datePicker.alpha = 0
            })
        } else {
            // update existing reminder
            msg = "Update"
            // set title
            txtTitle.text = r.title
            // set note
            txtViewNote.text = r.note
            // set datepicker
            if r.due == nil{
                datePicker.date = NSDate()
            } else {
                datePicker.date = r.due!
            }
            UIView.animateWithDuration(0.5, animations: {
                if self.r.due == nil {
                    self.segSwitch.selectedSegmentIndex = 1
                    self.datePicker.alpha = 0
                } else {
                    self.segSwitch.selectedSegmentIndex = 0
                    self.datePicker.alpha = 1
                }
            })
        }
        
        // common UI settings
        self.navigationItem.rightBarButtonItems = []
        let btnFinish:UIBarButtonItem = UIBarButtonItem(title: msg, style: .Done, target: self, action: #selector(btnFinishPerformed(_:)))
        if msg == "Uncheck"{
            self.navigationItem.title = "Check Reminder"
            btnFinish.tintColor = UIColor.redColor()
        } else{
            self.navigationItem.title = "\(msg!) Reminder"
        }
        self.navigationItem.rightBarButtonItems?.append(btnFinish)
        
        txtTitle.delegate = self
        txtTitle.returnKeyType = .Done
    }
    
    // set for display/hide date picker regard the user selection
    @IBAction func segSwitchValueChanged(sender: AnyObject) {
        if segSwitch.selectedSegmentIndex == 1{
            UIView.animateWithDuration(0.5, animations: {
                self.datePicker.alpha = 0
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.datePicker.alpha = 1
            })
        }
    }
    
    // user finish his work, I first validate everything, then check the current mode of this VC
    // then I do different process respectively
    func btnFinishPerformed(sender: AnyObject) {
        // validation
        if self.txtTitle.text == nil || (self.txtTitle.text?.isEmpty)!{
            let alert = UIAlertController(title: "Validation fail", message: "Title field is required", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // isEditReminder != nil means, the user is either creating a new reminder, or updating an existing one
            // both of which, need to read from UI and write data to core data
            if isEditReminder != nil{
                view.endEditing(true)
                // send the data back to homepage.
                // my design is to use a delegate.
                self.r.setValue(self.txtTitle.text!, forKey: "title")
                self.r.setValue(self.txtViewNote.text!, forKey: "note")
                self.r.setValue(false, forKey: "done")
                if segSwitch.selectedSegmentIndex == 1 {
                    self.r.setValue(nil, forKey: "due")
                } else {
                    self.r.setValue(datePicker.date, forKey: "due")
                }
    
                if !self.isEditReminder!{
                    self.remindersTableViewDelegate?.addReminder(self.r)
                } else {
                    self.remindersTableViewDelegate?.udpdateReminder()
                }
                self.isEditReminder = nil
            }
            // on the other hand, people can check or uncheck a reminder.
            else {
                r.isDone = !r.isDone
                self.remindersTableViewDelegate?.udpdateReminder()
            }
            reloadUI()
        }
    }
    
    // similar to finish button, but no need for precess data, we just set the mode back to check
    func btnCancelPerformed(sender: AnyObject){
        view.endEditing(true)
        if isEditReminder == nil{
            // check
            reloadUI()
        }else if isEditReminder!{
            //edit
            isEditReminder = nil
            self.remindersTableViewDelegate?.cancelEdit()
            reloadUI()
        }else {
            // create
            self.remindersTableViewDelegate?.displayHome()
            masterVC.view.userInteractionEnabled = true
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            view.endEditing(true)
        }
        return true
    }
}
