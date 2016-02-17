//
//  Account.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation

class Account: NSObject, NSCoding
{
    var Name: String?
    var Balance: Double!
    var StartDate: NSDate!
    
    override init()
    {
        Name = ""
        Balance = 0.0
    }
    
    func getDescription() -> String
    {
        return Name! + "::$" + String(format: "%.2f", Balance)
    }
    
    //NSCoding implementation
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        self.Name = aDecoder.decodeObjectForKey("Name") as? String
        self.Balance = aDecoder.decodeObjectForKey("Balance") as? Double
        self.StartDate = aDecoder.decodeObjectForKey("StartDate") as? NSDate
    }
    
    //NSCoding implementation
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(self.Name, forKey: "Name")
        aCoder.encodeObject(self.Balance, forKey: "Balance")
        aCoder.encodeObject(self.StartDate, forKey: "StartDate")
    }
}