//
//  TransactionCache.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation

class TransactionCache: NSObject, NSCoding
{
    var Transactions = [Transaction]()
    
    func CreateTransaction(thisTransaction: Transaction)-> Bool
    {
        Transactions.append(thisTransaction);
        DatabaseManager.InsertTransaction(thisTransaction)
        return true;
    }
    
    func RetrieveAllTransactions() -> [Transaction]
    {
        return Transactions;
    }
    
    func DeleteTransaction(thisTransaction: Transaction) -> Bool
    {
        var idx = 0;
        for entry in Transactions
        {
            if(entry.Name! == thisTransaction.Name!
            && entry.Amount == thisTransaction.Amount
            && entry.Date == thisTransaction.Date)
            {
                Transactions.removeAtIndex(idx);
                DatabaseManager.DeleteTransaction(thisTransaction.Id)
                break;
            }
            idx++;
        }
        return true;
    }
    
    //NSCoding implementation
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        self.Transactions = (aDecoder.decodeObjectForKey("Transactions") as? [Transaction])!
    }
    
    //NSCoding implementation
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(self.Transactions, forKey: "Transactions")
    }
    
    //Loads data from the database rather than archive
    func loadFromDb()->Bool
    {
        Transactions = DatabaseManager.GetAllTransactions()
        
        if(Transactions.count < 1)
        {
            return false
        }
        
        return true
    }
}