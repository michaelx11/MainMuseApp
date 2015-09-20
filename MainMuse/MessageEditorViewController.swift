//
//  MessageEditorViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/8/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class MessageEditorViewController: UIViewController, UIAlertViewDelegate {

    @IBOutlet var subjectTextView : UITextView!;
    @IBOutlet var bodyTextView : UITextView!;
    @IBOutlet var saveMessageButton : UIBarButtonItem!;
    
    let localData : AppLocalData = AppLocalData.sharedInstance

    var savedAlert : UIAlertView?
    var lock = false;
    var keyboardShowing : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        saveMessageButton.action = "saveMessage";
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        savedAlert = UIAlertView(title: "Saved!", message: "Your message has been uploaded!", delegate: self, cancelButtonTitle: nil)
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
        let messageData : MessageData = MessageData();
        messageData.subject = self.subjectTextView.text;
        messageData.body = self.bodyTextView.text;

        let messageJSON : String = messageData.toJsonString();

        var error : NSError?

        let sessionConfig : NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session : NSURLSession = NSURLSession(configuration: sessionConfig)
        let url = NSURL(string: "http://\(HOST)/\(localData.editType)message")
        let request : NSMutableURLRequest = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60.0)

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.HTTPMethod = "POST"

        let mapData : AnyObject = ["id": localData.localId, "token": localData.appAccessToken, "targetid": localData.targetUserId, "message": messageJSON, "index": localData.messageIndex]

        let postData : NSData = try! NSJSONSerialization.dataWithJSONObject(mapData, options: NSJSONWritingOptions())
        request.HTTPBody = postData

        let postDataTask : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data : NSData?, resp : NSURLResponse?, error : NSError?) in

            if let _ = error {
                self.lock = false
            } else {
                var err2: NSError?

                let jsonResult : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if(err2 != nil) {
                    // If there is an error parsing JSON, print it to the console
                    print("JSON Error \(err2!.localizedDescription)")
                    self.lock = false
                    return
                }
                if (jsonResult["error"] != nil) {
                    print(jsonResult["error"]);
                    self.lock = false
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        if (self.localData.editType == "append") {
                            print("Trying to call segue now");
                            self.performSegueWithIdentifier("unwindAfterAppendSegue", sender: self);
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.showSavedAlert()
                            })
                        }
                        self.lock = false;
                    });
                }
            }
        })
        postDataTask.resume()
    }
    
    func showSavedAlert() {
        savedAlert?.dismissWithClickedButtonIndex(-1, animated: false)
        savedAlert?.show()
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), {
            savedAlert?.dismissWithClickedButtonIndex(-1, animated: false)
        })
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
