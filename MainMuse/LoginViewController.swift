//
//  ViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/3/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

/*
protocol LoginViewControllerDelegate {
    func myVCDidFinish(controller:LoginViewController,text:String)
}
*/

class LoginViewController: UIViewController, FBLoginViewDelegate {
    

    
    @IBOutlet var fbLoginView : FBLoginView!;
    @IBOutlet var textView : UITextView!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("DID LOAD");
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fbLoginView.delegate = self;
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"];
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        println("User Logged In");
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        println("User: \(user)");
        println("User ID: \(user.objectID)");
        println("User Name: \(user.name)");
        var userEmail = user.objectForKey("email") as String;
        println("User Email: \(userEmail)");
        self.textView.text = "User Name: \(user.name)";
        
//        let appViewController : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("AppViewController");
//        self.navigationController?.pushViewController(appViewController as UIViewController, animated: true);
        performSegueWithIdentifier("loggedInSegue", sender: self)
        println("segueeee");
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User Logged Out");
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)");
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

