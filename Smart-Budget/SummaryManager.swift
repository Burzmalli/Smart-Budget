//
//  SummaryManager.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/13/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SummaryManager
{
    static private var managedObjectContext: NSManagedObjectContext?
    
    static var acctCache = AccountCache()
    static var transCache = TransactionCache()
    
    static var Balance = 0.0;
    static var PreviousTrans: Transaction?
    static var NextTrans: Transaction?
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let AcctURL = DocumentsDirectory.URLByAppendingPathComponent("accounts")
    static let TransURL = DocumentsDirectory.URLByAppendingPathComponent("transactions")
    
    static var Fetched = false
    
    //Instantiates the managedObjectContext, if nil, and then returns it
    static func GetContext()->NSManagedObjectContext
    {
        if(managedObjectContext == nil)
        {
            managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        }
        
        return managedObjectContext!
    }
    
    //Loads any existing accounts and transactions from core data
    static func FetchData()->Bool
    {
        if(Fetched)
        {
            return true;
        }
        
        var fetchRequest = NSFetchRequest(entityName: "Settings")
        
        do
        {
            let results = try GetContext().executeFetchRequest(fetchRequest)
            SettingsManager.CreateSettings(results[0] as! Settings)
        }
        catch
        {
            return false
        }
        
        if(SettingsManager.MySettings == nil || SettingsManager.MySettings!.username == nil || SettingsManager.MySettings!.username!.isEmpty)
        {
            return false;
        }
        
        fetchRequest = NSFetchRequest(entityName: "Account")
        
        do
        {
            let results = try GetContext().executeFetchRequest(fetchRequest)
            acctCache.Accounts = results as! [Account]
        }
        catch
        {
            return false
        }
        
        if(acctCache.Accounts.count < 1)
        {
            return false
        }
        
        fetchRequest = NSFetchRequest(entityName: "Transaction")
        
        do
        {
            let results = try GetContext().executeFetchRequest(fetchRequest)
            transCache.Transactions = results as! [Transaction]
            Fetched = true
        }
        catch
        {
            Fetched = false
        }
        
        return Fetched
    }
    
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
                if(PreviousTrans == nil || PreviousTrans!.date == nil
                    || trans.getLastDate(date).compare(PreviousTrans!.getLastDate(date)) == NSComparisonResult.OrderedDescending)
                {
                    PreviousTrans = trans
                }
            }

            if(NextTrans == nil || NextTrans!.date == nil
                || trans.getNextDate(date).compare(NextTrans!.getNextDate(date)) == NSComparisonResult.OrderedAscending)
            {
                NextTrans = trans
            }

        }
    }
    
    //Creates and returns a new account as part of the managedObjectContext
    static func GetAccount()->Account
    {
        let entityDescription = NSEntityDescription.entityForName("Account", inManagedObjectContext: GetContext())
        
        let anAccount = Account(entity: entityDescription!, insertIntoManagedObjectContext: GetContext())
        
        return anAccount
    }
    
    //Creates and returns a new transaction as part of the managedObjectContext
    static func GetTransaction()->Transaction
    {
        let entityDescription = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: GetContext())
        
        let aTransaction = Transaction(entity: entityDescription!, insertIntoManagedObjectContext: GetContext())
        
        return aTransaction
    }
}