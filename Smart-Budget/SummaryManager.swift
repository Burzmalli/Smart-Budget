//
//  SummaryManager.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/13/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData

class SummaryManager
{
    static let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    static var acctCache = AccountCache()
    static var transCache = TransactionCache()
    
    static var Balance = 0.0;
    static var PreviousTrans = Transaction()
    static var NextTrans = Transaction()
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let AcctURL = DocumentsDirectory.URLByAppendingPathComponent("accounts")
    static let TransURL = DocumentsDirectory.URLByAppendingPathComponent("transactions")
    
    //Updates the summary information based on the existing accounts and
    //transactions, projected out to the date that was passed in
    static func UpdateSummary(date: NSDate)
    {
        //Set balance to 0
        Balance = 0
        
        //Add the starting balance for each account
        for acct in acctCache.RetrieveAllAccounts()
        {
            Balance += acct.startingBalance as! Double
        }
        
        var recurred = 0
        
        //Add the value of each transaction multiplied by the number
        //of times that transaction has recurred
        for trans in transCache.RetrieveAllTransactions()
        {
            //Set number of times transaction has recurred
            recurred = trans.getRecurred(date)
            
            //If transaction date is the same or earlier than the date
            //that was passed in, add its amount * recurred to the balance
            if(trans.date!.compare(date) == NSComparisonResult.OrderedAscending
                || trans.date!.compare(date) == NSComparisonResult.OrderedSame)
            {
                Balance += (trans.amount as! Double) * Double(recurred);
                
                //Ensure the most recent transaction is set
                if(PreviousTrans.date == nil
                    || trans.getLastDate(date).compare(PreviousTrans.getLastDate(date)) == NSComparisonResult.OrderedDescending)
                {
                    PreviousTrans = trans
                }
            }
            else //Logic to set the next transaction variable
            {
                if(NextTrans.date == nil
                    || trans.getNextDate(date).compare(NextTrans.getNextDate(date)) == NSComparisonResult.OrderedAscending)
                {
                    NextTrans = trans
                }
            }
        }
    }
    
}