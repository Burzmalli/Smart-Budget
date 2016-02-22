//
//  AccountCache.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import Foundation

class AccountCache: NSObject, NSCoding
{
    var Accounts = [Account]()
    
    func CreateAccount(thisAccount: Account)-> Bool
    {
        //Verify new account is unique before adding
        if(IsAcctUnique(thisAccount))
        {
            Accounts.append(thisAccount);
            DatabaseManager.InsertAccount(thisAccount)
            return true;
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
            if(entry.Name! == thisAccount.Name!)
            {
                Accounts.removeAtIndex(idx);
                DatabaseManager.DeactivateAccount(thisAccount.Id)
                thisAccount.Active = false
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
            if( thisAccount.Name! == acct.Name!)
            {
                return false;
            }
        }
        
        return true;
    }
    
    //NSCoding implementation
    required convenience init?(coder aDecoder: NSCoder)
    {
        self.init()
        self.Accounts = (aDecoder.decodeObjectForKey("Accounts") as? [Account])!
    }
    
    //NSCoding implementation
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(self.Accounts, forKey: "Accounts")
    }
    
    func loadFromDb()->Bool
    {
        Accounts = DatabaseManager.GetAllAccounts()
        
        if(Accounts.count < 1)
        {
            return false
        }
        
        return true
    }
}