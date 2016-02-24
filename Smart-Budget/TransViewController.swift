//
//  TransViewController.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import UIKit

class TransViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    var selectedAccount: Account!
    
    @IBOutlet weak var transName: UITextField!
    
    @IBOutlet weak var transAmount: UITextField!
    
    @IBOutlet weak var transDate: UIDatePicker!
    
    @IBOutlet weak var transactionList: UITableView!
    
    @IBOutlet weak var acctPicker: UIPickerView!
    
    @IBOutlet weak var recurringSwitch: UISwitch!
    
    @IBAction func addTransaction(sender: AnyObject)
    {
        let aTransaction = Transaction()
        aTransaction.name = transName.text
        aTransaction.amount = Double(transAmount.text!)
        aTransaction.date = transDate.date
        aTransaction.account = selectedAccount
        aTransaction.recurring = recurringSwitch.on
        SummaryManager.transCache.CreateTransaction(aTransaction)
        transactionList.reloadData()
    }
    
    @IBAction func deleteTransaction(sender: AnyObject)
    {
        let aTransaction = Transaction()
        aTransaction.name = transName.text
        aTransaction.amount = Double(transAmount.text!)
        aTransaction.date = transDate.date
        aTransaction.account = selectedAccount
        SummaryManager.transCache.DeleteTransaction(aTransaction)
        transactionList.reloadData()
    }
    
    //UITableViewDelegate implementation
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SummaryManager.transCache.RetrieveAllTransactions().count
    }
    
    //UITableViewDelegate implementation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.transactionList.dequeueReusableCellWithIdentifier("transCell") as UITableViewCell!
        let localTransaction = SummaryManager.transCache.RetrieveAllTransactions()[indexPath.row]
        cell.textLabel?.text = localTransaction.getDescription()
        return cell
    }
    
    //UIPickerViewDelegate implementation
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //UIPickerViewDelegate implementation
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SummaryManager.acctCache.RetrieveAllAccounts().count
    }
    
    //UIPickerViewDelegate implementation
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SummaryManager.acctCache.RetrieveAllAccounts()[row].name
    }
    
    //UIPickerViewDelegate implementation
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedAccount = SummaryManager.acctCache.RetrieveAllAccounts()[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.transactionList.registerClass(UITableViewCell.self, forCellReuseIdentifier: "transCell")
        self.transDate.datePickerMode = UIDatePickerMode.Date
    }
    
    //Reload components for account picker when tab is selected
    override func viewWillAppear(animated: Bool) {
        acctPicker.reloadAllComponents()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
