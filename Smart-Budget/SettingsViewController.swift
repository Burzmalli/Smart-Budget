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
    
    @IBAction func saveSettings()
    {
        SettingsManager.MySettings?.username = username.text
        
        SettingsManager.MySettings?.authenticate = authenticate.on
    }
    
    @IBAction func resetAll()
    {
        let resetText = "All budget data and settings will be lost. Continue?"
        let refreshAlert = UIAlertController(title: "Reset", message: resetText, preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style:.Default, handler: { (action: UIAlertAction!) in
            self.resetBudget()
        } ))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style:.Default, handler: { (action: UIAlertAction!) in
            return
        } ))
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
        
        
        transitionToInitialScreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.text = SettingsManager.MySettings!.username
        
        authenticate.on = (SettingsManager.MySettings!.authenticate?.boolValue)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
