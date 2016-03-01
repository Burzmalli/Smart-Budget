//
//  FirstViewController.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 1/31/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController
{
    @IBOutlet weak var summaryDate: UIDatePicker!
    
    @IBOutlet weak var totalBalance: UILabel!
    
    @IBOutlet weak var lastAccount: UILabel!
    
    @IBOutlet weak var lastName: UILabel!
    
    @IBOutlet weak var lastDate: UILabel!
    
    @IBOutlet weak var lastValue: UILabel!
    
    @IBOutlet weak var nextAccount: UILabel!
    
    @IBOutlet weak var nextName: UILabel!
    
    @IBOutlet weak var nextDate: UILabel!
    
    @IBOutlet weak var nextValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryDate.datePickerMode = UIDatePickerMode.Date
        summaryDate.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        SummaryManager.FetchData()
        
        //Set the initial state of the summary fields
        UpdateSummaryFields()
    }
    
    //Update summary and labels when tab is selecte
    override func viewWillAppear(animated: Bool) {
        //Update the summary and labels any time that the user
        //selects the summary tab
        SummaryManager.UpdateSummary(summaryDate.date)
        UpdateSummaryFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func datePickerChanged(datePicker:UIDatePicker)
    {
        //Update the summary and labels any time the date changes
        SummaryManager.UpdateSummary(datePicker.date)
        UpdateSummaryFields()
    }
    
    //Updates the summary labels to reflect the SummaryManager's
    //information
    func UpdateSummaryFields()
    {
        SetLabelTextFromDollarValue(totalBalance, amt: SummaryManager.Balance)
        
        if(SummaryManager.PreviousTrans == nil || SummaryManager.PreviousTrans!.account == nil)
        {
            lastAccount.text = ""
        }
        else
        {
            lastAccount.text = SummaryManager.PreviousTrans!.account!.name
        }
        
        if(SummaryManager.PreviousTrans == nil)
        {
            lastName.text = ""
            
            SetLabelTextFromDollarValue(lastValue, amt: 0.0)
            
            lastDate.text = ""
        }
        else
        {
            lastName.text = SummaryManager.PreviousTrans!.name
            
            SetLabelTextFromDollarValue(lastValue, amt: SummaryManager.PreviousTrans!.amount as! Double)
            
            lastDate.text = SummaryManager.PreviousTrans!.getLastDateString(summaryDate.date)
        }
        
        if(SummaryManager.NextTrans == nil || SummaryManager.NextTrans!.account == nil)
        {
            nextAccount.text = ""
        }
        else
        {
            nextAccount.text = SummaryManager.NextTrans!.account!.name
        }
        
        if(SummaryManager.NextTrans == nil)
        {
            nextName.text = ""
            
            SetLabelTextFromDollarValue(nextValue, amt: 0.0)
            
            nextDate.text = ""
        }
        else
        {
            nextName.text = SummaryManager.NextTrans!.name
        
            SetLabelTextFromDollarValue(nextValue, amt: SummaryManager.NextTrans!.amount as! Double)
        
            nextDate.text = SummaryManager.NextTrans!.getNextDateString(summaryDate.date)
        }
    }
    
    //Sets a labels text to the formatted dollar value
    //and sets the color based on whether the value
    //is positive (black) or negative (red)
    func SetLabelTextFromDollarValue(label: UILabel, amt: Double)
    {
        label.text = "$" + String(format: "%.2f", amt)
        if(amt >= 0)
        {
            label.textColor = UIColor.blackColor()
        }
        else
        {
            label.textColor = UIColor.redColor()
        }
    }
}

