//
//  Category+CoreDataProperties.swift
//  fit5140assign1
//
//  Created by Jack N. Archer on 9/09/2016.
//  Copyright © 2016 Jack N. Archer. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Category {

    @NSManaged var color: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var radius: NSNumber?
    @NSManaged var title: String?
    @NSManaged var order: NSNumber?
    @NSManaged var from_re: NSSet?
    
    
    @NSManaged func addFrom_reObject(value:Reminder)
    @NSManaged func removeFrom_reObject(value:Reminder)

}
