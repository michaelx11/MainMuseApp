//
//  ViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/3/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    

    
    @IBOutlet var fbLoginView : FBLoginView!;
    @IBOutlet var textView : UITextView!;
    
    var fetchedUserInfo = false;
    
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

        localData.accessToken = FBSession.activeSession().accessTokenData.accessToken;
        localData.localId = user.objectID;
        localData.fullName = user.name;
        localData.localEmail = userEmail;
        println(localData.accessToken);
        
        if (!fetchedUserInfo) {
            verifyUserAndSegue(localData.localId, name: localData.fullName, email: localData.localEmail, accessToken: localData.accessToken);
            fetchedUserInfo = true;
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        println("User Logged Out");
        localData = AppLocalData();
        fetchedUserInfo = false;
    }
    
    func loginView(loginView: FBLoginView!, handleError: NSError) {
        println("Error: \(handleError.localizedDescription)");
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func verifyUserAndSegue(id: NSString, name: NSString, email: NSString, accessToken: NSString) {
        if (localData.verified) {
            return;
        }
        
        var rawPath : String = "http://" + HOST + ":9988/initializeuser?id=" + id + "&token=" + accessToken + "&name=" + name + "&email=" + email;
//        var urlPath : String = "http://view.ninja:9988/initializeuser?id=" + id + "&token=" + accessToken + "&name=" + name + "&email=" + email;
        let urlPath : String = rawPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
        println(urlPath);
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
                return;
            }
            var err: NSError?
            
            var jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            println(jsonResult);
            
            if (jsonResult["accesstoken"] != nil) {

                localData.appAccessToken = jsonResult["accesstoken"] as NSString;
                println(localData.appAccessToken);
                localData.verified = true;
                self.performSegueWithIdentifier("loggedInSegue", sender: self);
            } else {
                println(jsonResult["error"]);
            }

        })
        
        task.resume()
    }
    
}

