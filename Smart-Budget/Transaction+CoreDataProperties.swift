//
//  Transaction+CoreDataProperties.swift
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

extension Transaction {

    @NSManaged var amount: NSNumber?
    @NSManaged var category: String?
    @NSManaged var date: NSDate?
    @NSManaged var endDate: NSDate?
    @NSManaged var name: String?
    @NSManaged var recurring: NSNumber?
    @NSManaged var transId: NSNumber?
    @NSManaged var account: Account?

}
