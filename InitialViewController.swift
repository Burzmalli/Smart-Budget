//
//  InitialViewController.swift
//  Smart-Budget
//
//  Created by Joseph Williams on 3/4/16.
//  Copyright © 2016 Joseph Williams. All rights reserved.
//

import UIKit
import LocalAuthentication

class InitialViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var authenticate: UISwitch!
    
    @IBOutlet weak var firstAccountName: UITextField!
    
    @IBOutlet weak var firstAccountBalance: UITextField!
    
    @IBOutlet weak var passwordStack: UIStackView!
    
    @IBOutlet weak var initialStack: UIStackView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var passwordEntry: UITextField!
    
    @IBOutlet weak var passwordAuthenticate: UITextField!
    
    @IBOutlet weak var authenticatePasswordStack: UIStackView!
    
    private var newlyLaunched = true
    
    private var touchIdEnabled = false
    
    @IBAction func login()
    {
        if(passwordAuthenticate.text == SettingsManager.MySettings?.password)
        {
            transitionToMainScreen()
        }
    }
    
    @IBAction func switched()
    {
        //Show or hide password field depending on whether
        //user wants to use authentication
        if(authenticate.on)
        {
            passwordStack.hidden = false
        }
        else
        {
            passwordStack.hidden = true
        }
    }
    
    @IBAction func done()
    {
        //Set settings values
        SettingsManager.MySettings?.username = username.text
        SettingsManager.MySettings?.authenticate = authenticate.on
        SettingsManager.MySettings?.password = passwordEntry.text
        
        //Create initial account
        let anAccount = SummaryManager.GetAccount()
        anAccount.name = firstAccountName.text
        anAccount.startingBalance = NSNumber(double:Double(firstAccountBalance.text!)!)
        anAccount.active = NSNumber(bool: true)
        SummaryManager.acctCache.CreateAccount(anAccount)
        
        SummaryManager.SaveContext()
        
        //Show main screen
        transitionToMainScreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if existing data is present
        newlyLaunched = !SummaryManager.FetchData()
        
        if(!newlyLaunched)
        {
            //If previous data exists, authenticate (if set) or show main screen
            initialStack.hidden = true
            authenticatePasswordStack.hidden = false
            if(SettingsManager.MySettings!.authenticate!.boolValue)
            {
                authenticateUser()
            }
            else
            {
                transitionToMainScreen()
            }
        }
        else
        {
            //Otherwise, show setup fields
            initialStack.hidden = false
            authenticatePasswordStack.hidden = true
            SettingsManager.CreateSettings()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Loads the main screen
    func transitionToMainScreen()
    {
        //Get the Main storyboard and present it
        let mainView = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainView.instantiateInitialViewController()! as UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    //Function that handles the authentication evaluatio
    func evalAuthenticateSuccess(success: Bool, error: NSError?)
    {
        if(success)
        {
            //If successful load main screen
            transitionToMainScreen()
        }
    }
    
    func canTouch()->Bool
    {
        let context = LAContext();
        return context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    func authenticateUser()
    {
        var reason = ""
        
        if( !newlyLaunched )
        {
            reason = "Authentication is required to access your budget"
        }
        else
        {
            reason = "Use Touch ID to enable it for your budget"
        }
        
        if(canTouch())
        {
            LAContext().evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: evalAuthenticateSuccess)
        }
        else
        {
            if(newlyLaunched)
            {
                initialStack.hidden = false
                authenticatePasswordStack.hidden = true
            }
            else
            {
                initialStack.hidden = true
                authenticatePasswordStack.hidden = false
            }
        }
    }
}
