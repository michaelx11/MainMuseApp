//
//  ViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/3/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet var nameLabel : UILabel!;
    
    let localData : AppLocalData = AppLocalData.sharedInstance
    var loginView : FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("DID LOAD");
        // Do any additional setup after loading the view, typically from a nib.
        
        if loginView == nil {
            loginView = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
        
        self.nameLabel.text = String(localData.fullName);
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User shouldn't get here")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        performSegueWithIdentifier("loggedOutSegue", sender: self)
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

