//
//  TransactionCache.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData

class TransactionCache: NSObject
{
    var Transactions = [Transaction]()
    
    func CreateTransaction(thisTransaction: Transaction)-> Bool
    {
        Transactions.append(thisTransaction);
        let entityDescription = NSEntityDescription.entityForName("Transaction", inManagedObjectContext: SummaryManager.GetContext())
        let transaction = Transaction(entity: entityDescription!,insertIntoManagedObjectContext: SummaryManager.managedObjectContext)
        
        transaction.transId = thisTransaction.transId
        transaction.date = thisTransaction.date
        transaction.endDate = thisTransaction.endDate
        transaction.amount = thisTransaction.amount
        transaction.name = thisTransaction.name
        transaction.recurring = thisTransaction.recurring
        transaction.account = thisTransaction.account
        
        do
        {
            try SummaryManager.GetContext().save()
        }
        catch
        {
            
        }
        
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
            if(entry.name! == thisTransaction.name!
            && entry.amount == thisTransaction.amount
            && entry.date == thisTransaction.date)
            {
                Transactions.removeAtIndex(idx);
                break;
            }
            idx++;
        }
        return true;
    }
}