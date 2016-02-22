//
//  Transaction.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation

class Transaction: NSObject, NSCoding
{
    var Id: Int
    var Name: String?
    var Amount: Double!
    var Date: NSDate!
    var Acct: Account!
    var Recurring = false
    var EndDate: NSDate!
    
    override init()
    {
        Id = 0
        Name = ""
        Amount = 0.0
        Date = nil
        EndDate = NSDate.distantFuture()
        Acct = nil
    }
    
    //Converts the transaction date to a short string
    func getDateString()->String
    {
        if( Date == nil)
        {
            return ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(Date)
    }
    
    func getNextDateString(fromDate: NSDate)->String
    {
        if( Date == nil)
        {
            return ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(getNextDate(fromDate))
    }
    
    func getLastDateString(fromDate: NSDate)->String
    {
        if( Date == nil)
        {
            return ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(getLastDate(fromDate))
    }
    
    func getDescription()->String
    {
        let amt = String(format: "%.2f", Amount)
        let date = getDateString()
        
        if(Acct == nil)
        {
            return Name! + "::$" + amt + "::" + date
        }
        
        return Name! + "::$" + amt + "::" + date + "::" + Acct.Name!
    }
    
    //Returns the number of times that a transaction has recurred
    //from the start date to the date that is passed in.
    //Returns 1 if transaction is non-recurring
    func getRecurred(date: NSDate)->Int
    {
        //Return 0 if transaction date is alter than passed-in date
        if(self.Date.compare(date) == NSComparisonResult.OrderedDescending)
        {
            return 0
        }
        
        //Return 1 if transaction isn't recurring
        if(!Recurring)
        {
            return 1
        }
        
        //Return the number of times from start date to passed-in date
        //if still recurring (no EndDate)
        if(EndDate == NSDate.distantFuture())
        {
            return 1 + NSCalendar.currentCalendar().components(.Month, fromDate: Date, toDate: date, options: []).month
        }
        
        //Return the number of times from start date to end date if
        //no longer recurring
        return 1 + NSCalendar.currentCalendar().components(.Month, fromDate: Date, toDate: EndDate, options: []).month
    }
    
    //NSCoding implementation
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        self.Name = aDecoder.decodeObjectForKey("Name") as? String
        self.Amount = aDecoder.decodeObjectForKey("Amount") as? Double
        
        //Decode account if it exists
        let tempAcct = aDecoder.decodeObjectForKey("Account") as? Account
        if(tempAcct != nil)
        {
            self.Acct = tempAcct!
        }
        
        self.Date = aDecoder.decodeObjectForKey("Date") as? NSDate
        self.Recurring = aDecoder.decodeObjectForKey("Recurring") as! Bool
        
        //Decode EndDate if it exists
        let tempEndDate = aDecoder.decodeObjectForKey("EndDate") as? NSDate
        if(tempEndDate != nil)
        {
            self.EndDate = tempEndDate!
        }
        
    }
    
    //NSCoding implementation
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(self.Name, forKey: "Name")
        aCoder.encodeObject(self.Amount, forKey: "Amount")
        aCoder.encodeObject(self.Date, forKey: "Date")
        aCoder.encodeObject(self.Acct, forKey: "Account")
        aCoder.encodeObject(self.Recurring, forKey: "Recurring")
        
        //Encode EndDate if it exists
        if(self.EndDate != nil)
        {
            aCoder.encodeObject(self.EndDate, forKey:"EndDate")
        }
    }
    
    func getLastDate(fromDate: NSDate)->NSDate
    {
        if(!Recurring)
        {
            return Date
        }
        
        let recurred = getRecurred(fromDate) - 1
        
        let dateComponents = NSDateComponents()
        dateComponents.setValue(recurred, forComponent: NSCalendarUnit.Month)
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(dateComponents, toDate: Date, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func getNextDate(fromDate: NSDate)->NSDate
    {
        if(!Recurring)
        {
            return Date
        }
        
        let recurred = getRecurred(fromDate)
        
        let dateComponents = NSDateComponents()
        dateComponents.setValue(recurred, forComponent: NSCalendarUnit.Month)
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(dateComponents, toDate: Date, options: NSCalendarOptions(rawValue: 0))!
    }
}