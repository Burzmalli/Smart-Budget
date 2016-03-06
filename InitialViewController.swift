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
    
    private var newlyLaunched = true
    
    @IBAction func switched()
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
    
    @IBAction func done()
    {
        let anAccount = SummaryManager.GetAccount()
        anAccount.name = firstAccountName.text
        anAccount.startingBalance = NSNumber(double:Double(firstAccountBalance.text!)!)
        anAccount.active = NSNumber(bool: true)
        SummaryManager.acctCache.CreateAccount(anAccount)
        
        transitionToMainScreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newlyLaunched = !SummaryManager.FetchData()
        
        if(!newlyLaunched)
        {
            initialStack.hidden = true
            authenticateUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func transitionToMainScreen()
    {
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainView.instantiateInitialViewController()! as UIViewController
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func evalAuthenticateSuccess(success: Bool, error: NSError?)
    {
        if(success)
        {
            if(newlyLaunched)
            {
                
            }
            else
            {
                transitionToMainScreen()
            }
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
                
            }
        }
    }
    
    
}
