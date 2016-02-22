//
//  SummaryManager.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/13/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation

class SummaryManager
{
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
            Balance += acct.Balance
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
            if(trans.Date.compare(date) == NSComparisonResult.OrderedAscending
                || trans.Date.compare(date) == NSComparisonResult.OrderedSame)
            {
                Balance += trans.Amount * Double(recurred);
                
                //Ensure the most recent transaction is set
                if(PreviousTrans.Date == nil
                    || trans.getLastDate(date).compare(PreviousTrans.getLastDate(date)) == NSComparisonResult.OrderedDescending)
                {
                    PreviousTrans = trans
                }
            }
            else //Logic to set the next transaction variable
            {
                if(NextTrans.Date == nil
                    || trans.getNextDate(date).compare(NextTrans.getNextDate(date)) == NSComparisonResult.OrderedAscending)
                {
                    NextTrans = trans
                }
            }
        }
    }
    
    //Saves the budget to database, migrating from archive saving to database
    //Ensure backwards compatibility with previous versions
    static func SaveBudget()
    {
        var deleteArchive = true
        //Save all accounts to database
        for acct in acctCache.RetrieveAllAccounts()
        {
            if(!DatabaseManager.InsertAccount(acct))
            {
                deleteArchive = false
            }
        }
        
        //Save all transactions to database
        for trans in transCache.RetrieveAllTransactions()
        {
            if(!DatabaseManager.InsertTransaction(trans))
            {
                deleteArchive = false
            }
        }
        
        //If all saves passed, ensure budget can be loaded from database
        //then delete archives if save/load with database is successful
        if(deleteArchive)
        {
            if( LoadBudgetFromDb())
            {
                do
                {
                    try NSFileManager().removeItemAtURL(AcctURL)
                    try NSFileManager().removeItemAtURL(TransURL)
                }
                catch
                {
                    
                }
            }
        }
    }
    
    //Attempts to load budget from archive
    //Used only for backwards compatibility with previous versions
    static func LoadBudget()->Bool
    {
        //Attempt to load arrays from archive
        let tempAcctCache = NSKeyedUnarchiver.unarchiveObjectWithFile(AcctURL.path!) as? AccountCache
        let tempTransCache = NSKeyedUnarchiver.unarchiveObjectWithFile(TransURL.path!) as? TransactionCache
        
        //Set summary caches to loaded arrays if they aren't null
        if(tempAcctCache != nil)
        {
            acctCache = tempAcctCache!
        }
        else
        {
            return false
        }
        
        if(tempTransCache != nil)
        {
            transCache = tempTransCache!
        }
        else
        {
            return false
        }
        
        return true
    }
    
    //Loads budget from DB rather than archive
    static func LoadBudgetFromDb()->Bool
    {
        if(!acctCache.loadFromDb())
        {
            return false
        }
        
        if(!transCache.loadFromDb())
        {
            return false
        }
        
        UpdateSummary(NSDate())
        
        return true
    }
}