//
//  Account+CoreDataProperties.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/29/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Account {

    @NSManaged var accountId: NSNumber?
    @NSManaged var name: String?
    @NSManaged var startingBalance: NSNumber?
    @NSManaged var transactions: NSSet?
    @NSManaged var active: NSNumber?

}
