//
//  SettingsViewController.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 3/5/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var authenticate: UISwitch!
    
    @IBOutlet weak var passwordStack: UIStackView!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func authenticateSwitched()
    {
        if(authenticate.on)
        {
            passwordStack.hidden = false
        }
        else
        {
            passwordStack.hidden = true
        }
    }
    
    @IBAction func saveSettings()
    {
        SettingsManager.MySettings?.username = username.text
        
        SettingsManager.MySettings?.authenticate = authenticate.on
        
        SummaryManager.SaveContext()
    }
    
    @IBAction func resetAll()
    {
        //Create warning to user that all data will be reset
        let resetText = "All budget data and settings will be lost. Continue?"
        let resetAlert = UIAlertController(title: "Reset", message: resetText, preferredStyle: UIAlertControllerStyle.Alert)
        
        //If Yes is selected, call resetBudget
        resetAlert.addAction(UIAlertAction(title: "Yes", style:.Default, handler: { (action: UIAlertAction!) in
            self.resetBudget()
        } ))
        
        //If No, do nothing
        resetAlert.addAction(UIAlertAction(title: "No", style:.Default, handler: { (action: UIAlertAction!) in
            return
        } ))
        
        //Display warning
        self.presentViewController(resetAlert, animated: true, completion: nil)
    }
    
    func transitionToInitialScreen()
    {
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: "Initial", bundle: nil)
        let viewController = mainView.instantiateInitialViewController()! as UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func resetBudget()
    {
        SummaryManager.GetContext().deleteObject(SettingsManager.MySettings!)
        
        SummaryManager.SaveContext()
        
        transitionToInitialScreen()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        username.text = SettingsManager.MySettings!.username
        
        authenticate.on = (SettingsManager.MySettings!.authenticate?.boolValue)!
    }
    
    override func viewDidAppear(animated: Bool)
    {
        authenticate.on = (SettingsManager.MySettings?.authenticate?.boolValue)!
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}
