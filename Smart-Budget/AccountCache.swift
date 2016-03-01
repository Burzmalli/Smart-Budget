//
//  AccountCache.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation
import CoreData

class AccountCache: NSObject
{
    var Accounts = [Account]()
    
    func CreateAccount(thisAccount: Account)-> Bool
    {
        //Verify new account is unique before adding
        if(IsAcctUnique(thisAccount))
        {
            Accounts.append(thisAccount);
            
            do
            {
                try SummaryManager.GetContext().save()
            }
            catch
            {
                
            }
            
            return true;
        }
        else
        {
            SummaryManager.GetContext().deleteObject(thisAccount)
        }
        
        return false;
    }
    
    func RetrieveAllAccounts() -> [Account]
    {
        return Accounts;
    }
    
    func DeleteAccount(thisAccount: Account) -> Bool
    {
        var idx = 0;
        for entry in Accounts
        {
            if(entry.name! == thisAccount.name!)
            {
                Accounts.removeAtIndex(idx);
                thisAccount.active = false
                do
                {
                    try SummaryManager.GetContext().save()
                }
                catch
                {
                    return false
                }
                break;
            }
            idx++;
        }
        return true;
    }
    
    //Checks if account name already exists in cache
    func IsAcctUnique(thisAccount: Account) -> Bool
    {
        for acct in Accounts
        {
            if( thisAccount.name! == acct.name!)
            {
                return false;
            }
        }
        
        return true;
    }
}