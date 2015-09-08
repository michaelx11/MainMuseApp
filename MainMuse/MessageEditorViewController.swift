//
//  MessageEditorViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/8/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class MessageEditorViewController: UIViewController {

    @IBOutlet var subjectTextView : UITextView!;
    @IBOutlet var bodyTextView : UITextView!;
    @IBOutlet var saveMessageButton : UIBarButtonItem!;
    
    let localData : AppLocalData = AppLocalData.sharedInstance

    var lock = false;
    var keyboardShowing : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        saveMessageButton.action = "saveMessage";
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), {
            if (self.localData.editType == "edit") {
                self.subjectTextView.text = String(self.localData.editingMessage.subject);
                self.bodyTextView.text = String(self.localData.editingMessage.body);
            } else {
                self.subjectTextView.text = "";
                self.bodyTextView.text = "";
            }
       });
    }

    func saveMessage() {
        if (lock) {
            return;
        }
        lock = true;
        var messageData : MessageData = MessageData();
        messageData.subject = self.subjectTextView.text;
        messageData.body = self.bodyTextView.text;
        
        var messageJSON : String = messageData.toJsonString();
        
        var rawPath : String = "http://\(HOST)/\(localData.editType)message?id=\(localData.localId)&token=\(localData.appAccessToken)&targetid=\(localData.targetUserId)&message=\(messageJSON)&index=\(localData.messageIndex)";
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
            if (jsonResult["error"] != nil) {
                println(jsonResult["error"]);
            } else {
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if (self.localData.editType == "append") {
                    println("Trying to call segue now");
                    self.performSegueWithIdentifier("unwindAfterAppendSegue", sender: self);
                }
                self.lock = false;
            });
        })
        task.resume();
    }

    
    func keyboardShow(n:NSNotification) {
        self.keyboardShowing = true
        
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        r = self.bodyTextView.convertRect(r, fromView:nil)
        self.bodyTextView.contentInset.bottom = r.size.height
        self.bodyTextView.scrollIndicatorInsets.bottom = r.size.height
    }
    
    func keyboardHide(n:NSNotification) {
        self.keyboardShowing = false
        self.bodyTextView.contentInset = UIEdgeInsetsZero
        self.bodyTextView.scrollIndicatorInsets = UIEdgeInsetsZero
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
