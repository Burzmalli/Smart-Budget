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
                    || trans.Date.compare(PreviousTrans.Date) == NSComparisonResult.OrderedDescending)
                {
                    PreviousTrans = trans
                }
            }
            else //Logic to set the next transaction variable
            {
                if(NextTrans.Date == nil
                    || trans.Date.compare(NextTrans.Date) == NSComparisonResult.OrderedAscending)
                {
                    NextTrans = trans
                }
            }
        }
    }
    
    //Saves the budget to archive in the form of accounts and
    //transactions arrays
    static func SaveBudget()
    {
        NSKeyedArchiver.archiveRootObject(acctCache, toFile: AcctURL.path!)
        NSKeyedArchiver.archiveRootObject(transCache, toFile: TransURL.path!)
    }
    
    //Loads the budget (accounts and transactions arrays) from
    //archive
    static func LoadBudget()
    {
        //Attempt to load arrays from archive
        let tempAcctCache = NSKeyedUnarchiver.unarchiveObjectWithFile(AcctURL.path!) as? AccountCache
        let tempTransCache = NSKeyedUnarchiver.unarchiveObjectWithFile(TransURL.path!) as? TransactionCache
        
        //Set summary caches to loaded arrays if they aren't null
        if(tempAcctCache != nil)
        {
            acctCache = tempAcctCache!
        }
        
        if(tempTransCache != nil)
        {
            transCache = tempTransCache!
        }
    }
}