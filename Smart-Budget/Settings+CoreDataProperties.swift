//
//  Settings+CoreDataProperties.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 3/2/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Settings {

    @NSManaged var username: String?
    @NSManaged var authenticate: NSNumber?
    @NSManaged var useTouchId: NSNumber?
    @NSManaged var password: String?

}
