//
//  ReminderDetailViewController.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 8/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//

import UIKit
import CoreData

class ReminderDetailViewController: UIViewController{

    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtViewNote: UITextView!
    @IBOutlet weak var segSwitch: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var managedObjectContext:NSManagedObjectContext?
    
    var isEditReminder:Bool = false
    var r:Reminder!
    override func viewDidLoad() {
        super.viewDidLoad()
        r = Reminder(entity: NSEntityDescription.entityForName("Reminder", inManagedObjectContext: self.managedObjectContext!)!, insertIntoManagedObjectContext: self.managedObjectContext!)
        datePicker.datePickerMode = .DateAndTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
