//
//  Account.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/23/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData


class Account: NSManagedObject
{
    func getDescription() -> String
    {
        return name! + "::$" + String(format: "%.2f", startingBalance!)
    }
}
