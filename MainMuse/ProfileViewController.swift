//
//  ViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/3/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {
    
    
    
    @IBOutlet var fbLogoutView : FBLoginView!;
    @IBOutlet var nameLabel : UILabel!;
    
    let localData : AppLocalData = AppLocalData.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("DID LOAD");
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fbLogoutView.delegate = self;
        self.fbLogoutView.readPermissions = ["public_profile", "email", "user_friends"];
        self.nameLabel.text = String(localData.fullName);
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User Logged In");
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println("User: \(user)");
        println("User ID: \(user.objectID)");
        println("User Name: \(user.name)");
        var userEmail = user.objectForKey("email") as! String;
        println("User Email: \(userEmail)");
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User Logged Out");
        performSegueWithIdentifier("loggedOutSegue", sender: self)
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)");
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

