//
//  Transaction.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/23/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData


class Transaction: NSManagedObject
{
    
    //Converts the transaction date to a short string
    func getDateString()->String
    {
        if( date == nil)
        {
            return ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(date!)
    }
    
    func getNextDateString(fromDate: NSDate)->String
    {
        if( date == nil)
        {
            return ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(getNextDate(fromDate))
    }
    
    func getLastDateString(fromDate: NSDate)->String
    {
        if( date == nil)
        {
            return ""
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        return formatter.stringFromDate(getLastDate(fromDate))
    }
    
    func getDescription()->String
    {
        let amt = String(format: "%.2f", amount!.doubleValue)
        let date = getDateString()
        
        if(account == nil)
        {
            return name! + "::$" + amt + "::" + date
        }
        
        return name! + "::$" + amt + "::" + date + "::" + account!.name!
    }

    //Returns the number of times that a transaction has recurred
    //from the start date to the date that is passed in.
    //Returns 1 if transaction is non-recurring
    func getRecurred(toDate: NSDate)->Int
    {
        //Return 0 if transaction date is alter than passed-in date
        if(self.date!.compare(toDate) == NSComparisonResult.OrderedDescending)
        {
            return 0
        }
        
        //Return 1 if transaction isn't recurring
        if((recurring == nil))
        {
            return 1
        }
        
        //Return the number of times from start date to passed-in date
        //if still recurring (no EndDate)
        if(endDate == NSDate.distantFuture())
        {
            return 1 + NSCalendar.currentCalendar().components(.Month, fromDate: date!, toDate: toDate, options: []).month
        }
        
        //Return the number of times from start date to end date if
        //no longer recurring
        return 1 + NSCalendar.currentCalendar().components(.Month, fromDate: date!, toDate: endDate!, options: []).month
    }
    
    func getLastDate(fromDate: NSDate)->NSDate
    {
        if((recurring == nil))
        {
            return date!
        }
        
        let recurred = getRecurred(fromDate) - 1
        
        let dateComponents = NSDateComponents()
        dateComponents.setValue(recurred, forComponent: NSCalendarUnit.Month)
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(dateComponents, toDate: date!, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func getNextDate(fromDate: NSDate)->NSDate
    {
        if((recurring == nil))
        {
            return date!
        }
        
        let recurred = getRecurred(fromDate)
        
        let dateComponents = NSDateComponents()
        dateComponents.setValue(recurred, forComponent: NSCalendarUnit.Month)
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(dateComponents, toDate: date!, options: NSCalendarOptions(rawValue: 0))!
    }
}
