//
//  ViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/3/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var loginView : FBSDKLoginButton!
    @IBOutlet var textView : UITextView!
    
    var fetchedUserInfo = false
    let localData : AppLocalData = AppLocalData.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            print("Already logged in!")
            localData.accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            fetchUserData()
        }
        else
        {
            loginView = FBSDKLoginButton()
            self.view.addSubview(loginView)
            loginView.center = self.view.center
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        // Reset this flag
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            self.fetchedUserInfo = false
            localData.verified = false
        }
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
            print(error)
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Result was cancelled")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile") && result.grantedPermissions.contains("user_friends")
            {
                localData.accessToken = result.token.tokenString
                print(result.token.expirationDate)
                fetchUserData()
                // Do work
                print(result)
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func fetchUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let fullName : NSString = result.valueForKey("name") as! NSString
                let userEmail : NSString = result.valueForKey("email") as! NSString
                let objectId : NSString = result.valueForKey("id") as! NSString
                self.localData.localId = objectId as String
                self.localData.fullName = fullName as String
                self.localData.localEmail = userEmail as String
                
                if (!self.fetchedUserInfo) {
                    self.verifyUserAndSegue(self.localData.localId, name: self.localData.fullName, email: self.localData.localEmail, accessToken: self.localData.accessToken);
                    self.fetchedUserInfo = true;
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyUserAndSegue(id: String, name: String, email: String, accessToken: String) {
        if (localData.verified) {
            return;
        }
        
        let rawPath : String = "http://" + HOST + "/initializeuser?id=" + id + "&token=" + accessToken + "&name=" + name + "&email=" + email;
        let urlPath : String = rawPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
        print(urlPath);
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            print("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
                return;
            }
            var err: NSError?
            
            let jsonResult : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                print("JSON Error \(err!.localizedDescription)")
            }
            print(jsonResult);
            
            dispatch_async(dispatch_get_main_queue(), {
                if (jsonResult["accesstoken"] != nil) {

                    self.localData.appAccessToken = jsonResult["accesstoken"] as! String;
                    print(self.localData.appAccessToken);
                    self.localData.verified = true;
                    self.performSegueWithIdentifier("loggedInSegue", sender: self);
                } else {
                    print(jsonResult["error"]);
                }
            });

        })
        
        task.resume()
    }
    
}

