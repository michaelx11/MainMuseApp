//
//  ReaderViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/5/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class ReaderViewController: UIViewController {

    @IBOutlet var subjectLabel : UILabel!;
    @IBOutlet var navItemView : UINavigationItem!;
    @IBOutlet var textView : UITextView!;
    
    var friendName : NSString!;
    var friendId : NSString!;
    var myId : NSString!;
    var myToken : NSString!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navItemView.title = "From: " + friendName;
    }

    override func viewWillAppear(animated: Bool) {
        getMessage();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessage() {
        var rawPath : String = "http://" + HOST + ":9988/readmessage?id=" + localData.localId + "&token=" + localData.appAccessToken + "&sourceid=" + friendId;
        let urlPath : String = rawPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
        println(urlPath);
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
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
                return;
            }
            if (jsonResult["error"] != nil) {
                println(jsonResult["error"]);
                dispatch_async(dispatch_get_main_queue(), {
                    self.subjectLabel.text = "Couldn't obtain message.";
                    self.textView.text = "Perhaps no messages have been sent!";
                })
            } else {
                let message : NSDictionary = jsonResult["message"] as NSDictionary;
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.subjectLabel.text = message["subject"] as NSString;
                    self.textView.text = message["body"] as NSString;
                })
            }
        })
        task.resume()
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
