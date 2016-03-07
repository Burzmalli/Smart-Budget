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
        
        SummaryManager.SaveContext()
        
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
                SummaryManager.GetContext().deleteObject(entry)
                SummaryManager.SaveContext()
                break;
            }
            idx++;
        }
        return true;
    }
}