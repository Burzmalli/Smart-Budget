//
//  DatabaseManager.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 2/20/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation

class DatabaseManager
{
    static let DatabaseFile = "budget.db"
    static var Connected = false
    static var BudgetDatabase: FMDatabase?
    
    //Connect to the database indicated by the DatabaseFile constant
    static func ConnectToDatabase()->Bool
    {
        //Close and reconnect if already connected
        if( Connected && BudgetDatabase != nil)
        {
            BudgetDatabase!.close()
            Connected = false
        }

        //Set DB path
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        let dbPath = docsDir.stringByAppendingPathComponent(DatabaseFile)
        
        //Backwards compatibility with previous version
        //If the file doesn't exist, load from archive,
        //create database, and save to the database
        if(SummaryManager.LoadBudget())
        {
            CreateDatabase(true)
            SummaryManager.SaveBudget()
        }
        
        //Instantiate FMDatabase, if not yet instantiated
        if(BudgetDatabase == nil)
        {
            BudgetDatabase = FMDatabase(path: dbPath as String)
        }
        
        //Open DB connection
        if(BudgetDatabase != nil && !Connected)
        {
            if(BudgetDatabase!.open())
            {
                Connected = true
            }
        }
        
        return Connected;
    }
    
    //Creates the budget database; overrides existing database is overrideDb set to true
    //Returns true if a new DB is created, otherwise false
    static func CreateDatabase(overrideDb: Bool = false)->Bool
    {
        //Create dbPath
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        let dbPath = docsDir.stringByAppendingPathComponent(DatabaseFile)
        
        //If DB file exists, delete it if override is set to true, otherwise
        //return false
        if(fileMgr.fileExistsAtPath(dbPath))
        {
            if( !overrideDb)
            {
                return false
            }
            
            do
            {
                try fileMgr.removeItemAtPath(dbPath)
            }
            catch
            {
                return false
            }
        }
        
        //Instantiate FMDatabase; return false if fails
        BudgetDatabase = FMDatabase(path: dbPath as String)
        
        if(BudgetDatabase == nil)
        {
            return false;
        }
        
        //If database can be opened, create tables
        if(BudgetDatabase!.open())
        {
            //statement for AccountsTable
            var sqlStmnt = "CREATE TABLE AccountsTable(" +
                "AcctId INTEGER PRIMARY KEY, " +
                "AcctName NVARCHAR(256), " +
                "StartingBalance DOUBLE, " +
                "Active INTEGER);"
            
            if(!BudgetDatabase!.executeStatements(sqlStmnt as String) )
            {
                return false
            }
            
            //statement for TransactionsTable
            sqlStmnt = "CREATE TABLE TransactionsTable(" +
                "TransId INTEGER PRIMARY KEY, " +
                "TransName NVARCHAR(256), " +
                "TransDate NVARCHAR(100), " +
                "TransEndDate NVARCHAR(100), " +
                "TransAmt DOUBLE, " +
                "IsRecurring INTEGER, " +
                "TransAcctId INTEGER, " +
                "FOREIGN KEY(TransAcctId) REFERENCES AccountsTable(AcctId));"
            
            if(!BudgetDatabase!.executeStatements(sqlStmnt as String) )
            {
                return false
            }
            
            Connected = true
        }
        else
        {
            return false
        }
        
        return true
    }
    
    //Inserts a new account into the database
    static func InsertAccount(toInsert: Account)->Bool
    {
        //Inser command
        var sqlCmd = "INSERT INTO AccountsTable (AcctName, StartingBalance, Active) VALUES ('\(toInsert.Name!)', \(toInsert.Balance), \(Int(true)))"
        
        //Attempt to execute insert
        if(!BudgetDatabase!.executeUpdate(sqlCmd, withArgumentsInArray: nil))
        {
            return false;
        }
        
        //Get greatest AcctId after insert and set the inserted account's id
        sqlCmd = "SELECT * FROM AccountsTable ORDER BY AcctId DESC LIMIT 1"
        
        let result = BudgetDatabase!.executeQuery(sqlCmd, withArgumentsInArray: nil)
        
        while result!.next() == true
        {
            toInsert.Id = Int(result.intForColumn("AcctId"))
        }
        
        return true
    }
    
    //Gets an array of all accounts in database
    static func GetAllAccounts()->[Account]
    {
        var Accounts = [Account]()
        
        var tempAcct: Account!
        
        let sqlCmd = "SELECT * FROM AccountsTable"
        
        let result = BudgetDatabase!.executeQuery(sqlCmd, withArgumentsInArray: nil)
        
        while result?.next() == true
        {
            tempAcct = Account()
            tempAcct.Id = Int(result.intForColumn("AcctId"))
            tempAcct.Name = result.stringForColumn("AcctName")!
            tempAcct.Balance = result.doubleForColumn("StartingBalance")
            Accounts.append(tempAcct)
        }
        
        return Accounts
    }
    
    //Gets a specific account by id
    static func GetAccount(id: Int)->Account
    {
        let sqlCmd = "SELECT * FROM AccountsTable WHERE AcctId = " + String(id) + " LIMIT 1"
        
        let result = BudgetDatabase!.executeQuery(sqlCmd, withArgumentsInArray: nil)
        
        var tempAcct: Account!
        
        while result?.next() == true
        {
            tempAcct = Account()
            tempAcct.Id = Int(result.intForColumn("AcctId"))
            tempAcct.Name = result.stringForColumn("AcctName")
            tempAcct.Balance = result.doubleForColumn("StartingBalance")
        }
        
        return tempAcct
    }
    
    //Deactivates account with passed id
    //Accounts remain referenced by existing transactions, so they cannot be deleted
    static func DeactivateAccount(id: Int)->Bool
    {
        let updateCmd = "UPDATE AccountsTable SET Active = \(Int(false))"
        
        return BudgetDatabase!.executeUpdate(updateCmd, withArgumentsInArray: nil)
    }
    
    //Activate a previously deactivated account with passed id
    static func ActivateAccount(id: Int)->Bool
    {
        let updateCmd = "UPDATE AccountsTable SET Active = \(Int(true))"
        
        return BudgetDatabase!.executeUpdate(updateCmd, withArgumentsInArray: nil)
    }
    
    //Inserts a transaction into the database
    static func InsertTransaction(toInsert: Transaction)->Bool
    {
        var acctId: Int
        if( toInsert.Acct == nil)
        {
            acctId = 1
        }
        else
        {
            acctId = toInsert.Acct.Id
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = .ShortStyle
        let dateString = dateFormatter.stringFromDate(toInsert.Date)
        let endDateString = dateFormatter.stringFromDate(toInsert.EndDate)
        
        //Command to insert transaction
        var sqlCmd = "INSERT INTO TransactionsTable (TransName, TransDate, TransEndDate, TransAmt, IsRecurring, TransAcctId) VALUES ('\(toInsert.Name)', '\(dateString)', '\(endDateString)', \(toInsert.Amount), \(Int(toInsert.Recurring)), \(acctId))"
        
        if(!BudgetDatabase!.executeUpdate(sqlCmd, withArgumentsInArray: nil))
        {
            return false
        }
        
        //Get largest trans id and set the inserted transaction's id to it
        sqlCmd = "SELECT * FROM TransactionsTable ORDER BY TransId DESC LIMIT 1"
        
        let result = BudgetDatabase!.executeQuery(sqlCmd, withArgumentsInArray: nil)
        
        while result!.next() == true
        {
            toInsert.Id = Int(result.intForColumn("TransId"))
        }
        
        return true
    }
    
    //Retrieves all transactions from the database
    static func GetAllTransactions()->[Transaction]
    {
        var Transactions = [Transaction]()
        
        var tempTrans:Transaction
        
        let sqlCmd = "SELECT * FROM TransactionsTable"
        
        let result = BudgetDatabase!.executeQuery(sqlCmd, withArgumentsInArray: nil)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        dateFormatter.timeStyle = .ShortStyle
        
        while result?.next() == true
        {
            tempTrans = Transaction()
            tempTrans.Id = Int(result.intForColumn("TransId"))
            tempTrans.Name = result.stringForColumn("TransName")!
            tempTrans.Amount = result.doubleForColumn("TransAmt")
            tempTrans.Date = dateFormatter.dateFromString(result.stringForColumn("TransDate"))
            tempTrans.Recurring = result.boolForColumn("IsRecurring")
            tempTrans.Acct = GetAccount(Int(result.intForColumn("TransAcctId")))
            tempTrans.EndDate = dateFormatter.dateFromString(result.stringForColumn("TransEndDate"))
            Transactions.append(tempTrans)
        }
        
        return Transactions
    }
    
    //Deactivates a recurring transaction with the passed id
    static func StopTransaction(Id: Int)->Bool
    {
        let updateCmd = "UPDATE TransactionsTable SET IsRecurring=\(Int(false)) WHERE TransId=\(Id)"
        
        return BudgetDatabase!.executeUpdate(updateCmd, withArgumentsInArray: nil)
    }
    
    //Deletes a transaction from the database with passed id
    static func DeleteTransaction(Id: Int)->Bool
    {
        let deleteCmd = "DELETE FROM TransactionsTable WHERE TransId=\(Id)"
        
        return BudgetDatabase!.executeUpdate(deleteCmd, withArgumentsInArray: nil)
    }
}