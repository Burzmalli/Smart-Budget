//
//  SecondViewController.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import UIKit

class AcctViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var acctName: UITextField!
    
    @IBOutlet weak var acctBalance: UITextField!
    
    @IBOutlet weak var accountList: UITableView!
    
    @IBAction func addAccount(sender: AnyObject)
    {
        let anAccount = Account();
        anAccount.name = acctName.text;
        anAccount.startingBalance = Double(acctBalance.text!);
        SummaryManager.acctCache.CreateAccount(anAccount)
        accountList.reloadData()
    }
    
    @IBAction func deleteAccount(sender: AnyObject)
    {
        let anAccount = Account();
        anAccount.name = acctName.text;
        anAccount.startingBalance = Double(acctBalance.text!)
        SummaryManager.acctCache.DeleteAccount(anAccount)
        accountList.reloadData()
    }
    
    //UITableViewDelegate implementation
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return SummaryManager.acctCache.RetrieveAllAccounts().count
    }
    
    //UITableViewDelegate implementation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.accountList.dequeueReusableCellWithIdentifier("acctCell") as UITableViewCell!
        let localAccount = SummaryManager.acctCache.RetrieveAllAccounts()[indexPath.row]
        cell.textLabel?.text = localAccount.getDescription()
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.accountList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "acctCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

