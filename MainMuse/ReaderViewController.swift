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
    @IBOutlet var listAllButton : UIBarButtonItem!;
    
    let localData : AppLocalData = AppLocalData.sharedInstance
    
    var friendName : String!;
    var friendId : String!;
    var myId : String!;
    var myToken : String!;
    var isLandingPage: Bool!; // whether this is the current message, and if we should show listAllButton
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navItemView.title = "From: " + friendName;
        if (isLandingPage != nil && !isLandingPage) {
            listAllButton.style = UIBarButtonItemStyle.Plain;
            listAllButton.enabled = false;
            listAllButton.title = nil;
        }
    }

    override func viewWillAppear(animated: Bool) {
        getMessage();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessage() {
        if (isLandingPage != nil && !isLandingPage) {
            dispatch_async(dispatch_get_main_queue(), {
                self.subjectLabel.text = self.localData.editingMessage.subject;
                self.textView.text = self.localData.editingMessage.body;
            })
            return;
        }
        var rawPath : String = "http://" + HOST + "/readmessage?id=" + localData.localId + "&token=" + localData.appAccessToken + "&sourceid=" + friendId;
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
            
            var jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                return;
            }

            var didEncounterError = false
            if (jsonResult["error"] != nil) {
                println(jsonResult["error"])
                didEncounterError = true
            } else {
                if let base64Message : String = jsonResult["message"] as? String {
                    println(base64Message)
                    if let tempMessage = MessageData(messageIndex: "", base64: base64Message) {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.subjectLabel.text = tempMessage.subject;
                            self.textView.text = tempMessage.body;
                        })
                    } else {
                        didEncounterError = true
                    }
                } else {
                    didEncounterError = true
                }
                
                if (didEncounterError) {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.subjectLabel.text = "Couldn't obtain message.";
                        self.textView.text = "Perhaps no messages have been sent!";
                    })
                }
            }
        })
        task.resume()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (sender is UIBarButtonItem) {
            if (segue.identifier == "listAllSegue") {
                let readListController : MessageReaderListController = segue.destinationViewController as! MessageReaderListController;
                readListController.friendId = self.friendId;
                readListController.friendName = self.friendName;
                readListController.myToken = self.myToken;
                readListController.myId = self.myId;
            }
        }
    }


}
