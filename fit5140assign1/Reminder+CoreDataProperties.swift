//
//  Reminder+CoreDataProperties.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 8/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reminder {

    @NSManaged var note: String?
    @NSManaged var title: String?
    @NSManaged var due: NSDate?
    @NSManaged var done: NSNumber?
    @NSManaged var re_to_cat: Category?

    
    var isDone:Bool{
        get{
            if done == nil { return false }
            else { return Bool(done!) }
        }
        set{
           done = NSNumber(bool: newValue)
        }
    }
}
