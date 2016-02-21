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
    
    //Connect to a database indicated by dbFile
    static func ConnectToDatabase(dbFile: NSString)->Bool
    {
        if( Connected && BudgetDatabase != nil)
        {
            BudgetDatabase!.close()
            Connected = false
        }
        
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        let dbPath = docsDir.stringByAppendingPathComponent(DatabaseFile)
        
        //Backwards compatibility with previous version
        //If the file doesn't exist, load from archive,
        //create database, and save to the database
        if(!fileMgr.fileExistsAtPath(dbPath))
        {
            SummaryManager.LoadBudget()
            CreateDatabase()
            
            SummaryManager.SaveBudget()
        }
        
        BudgetDatabase = FMDatabase(path: dbPath as String)
        
        if(BudgetDatabase != nil)
        {
            if(BudgetDatabase!.open())
            {
                Connected = true
            }
        }
        
        return Connected;
    }
    
    static func CreateDatabase(overrideDb: Bool = false)->Bool
    {
        let fileMgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as NSString
        let dbPath = docsDir.stringByAppendingPathComponent(DatabaseFile)
        
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
        
        BudgetDatabase = FMDatabase(path: dbPath as String)
        
        if(BudgetDatabase == nil)
        {
            return false;
        }
        
        if(BudgetDatabase!.open())
        {
            var sqlStmnt = "CREATE TABLE AccountsTable(" +
                "AcctId INTEGER PRIMARY KEY, " +
                "AcctName NVARCHAR(256), " +
            "StartingBalance DOUBLE);"
            
            if(!BudgetDatabase!.executeStatements(sqlStmnt as String) )
            {
                return false
            }
            
            sqlStmnt = "CREATE TABLE TransactionsTable(" +
                "TransId INTEGER PRIMARY KEY, " +
                "TransName NVARCHAR(256), " +
                "TransDate INTEGER, " +
                "TransAcct INTEGER, " +
                "FOREIGN KEY(TransAcct) REFERENCES AccountsTable(AcctId), " +
            "IsRecurring INTEGER);"
            
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
}