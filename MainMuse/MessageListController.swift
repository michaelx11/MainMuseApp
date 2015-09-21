//
//  MessageListController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

// Note: UITextViewDelegate to capture taps on subjectTextView without allowing editing
class MessageListController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

    var friendName : String!;
    var friendId : String!;
    var myId : String!;
    var myToken : String!;
    
    var messageList : [MessageData] = [];
    
    var isWaitingForSegue : Bool = false

    let localData : AppLocalData = AppLocalData.sharedInstance
    
    @IBOutlet var messageTable : UITableView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        messageTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Remove auto-padding for UITextViews
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated : Bool) {
        self.navigationItem.title = String(friendName);
        isWaitingForSegue = false
        getMessages();
    }
    
    func getMessages() {
        var rawPath : String = "http://\(HOST)/getmessagelist?id=\(localData.localId)&token=\(localData.appAccessToken)&targetid=\(friendId)";
        let urlPath : String = rawPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                print(error!.localizedDescription)
                return;
            }
            var err: NSError?
            
            var jsonResult : NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                print("JSON Error \(err!.localizedDescription)")
                return;
            }
            if (jsonResult["error"] != nil) {
                print(jsonResult["error"]);
            } else {
                let messages : NSDictionary = jsonResult["messages"] as! NSDictionary;
                var keys : [NSInteger] = [];
                for (index, message) in messages {
                    keys.append(index.integerValue);
                }
                let sortedKeys = keys.sort(<).map({"\($0)"});
                
                self.messageList = [];
                for index : String in sortedKeys {
                    if let base64Message : String = messages[index] as? String {
                        if let tempMessage = MessageData(messageIndex: index, base64: base64Message) {
                            self.messageList.append(tempMessage)
                        } else {
                            print("Error: couldn't parse message")
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.messageTable.reloadData();
                })
            }
        })
        task.resume();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return messageList.count
    }
    
    var firstView = true;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) ;
        
        let subjectTextView: UITextView = cell.contentView.viewWithTag(1) as! UITextView
        let bodyTextView: UITextView = cell.contentView.viewWithTag(2) as! UITextView
        
        if (indexPath.row >= messageList.count) {
            return cell;
        }
        
        // Catch tap events
        subjectTextView.delegate = self
        
        let message : MessageData = messageList[indexPath.row];
        subjectTextView.text = "\(message.index). \(message.subject)";
        bodyTextView.text = message.body
        
        // Need to be editable / selectable to allow font resizing, make them uneditable after
        // subjectTextView is editable to capture tap events
        bodyTextView.editable = false
        bodyTextView.selectable = false
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160.0
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        // Determine which row was picked
        let pointInTable: CGPoint = textView.convertPoint(textView.bounds.origin, toView:messageTable)
        let indexPath: NSIndexPath = messageTable.indexPathForRowAtPoint(pointInTable)!
        
        if indexPath.row < 0 || indexPath.row >= messageList.count {
            return false
        }

        if isWaitingForSegue {
            return false
        }
        isWaitingForSegue = true

        // Set appropriate data before segue
        localData.targetUserId = friendId
        localData.editType = "edit"
        localData.messageIndex = messageList[indexPath.row].index
        localData.editingMessage = messageList[indexPath.row]
        
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("editMessageSegue", sender: self)
        })
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editMessageSegue") {
            // do nothing
//            let senderButton : FriendButton = sender as! FriendButton;
//            localData.targetUserId = friendId;
//            localData.editType = "edit";
//            localData.messageIndex = senderButton.index;
//            localData.editingMessage = senderButton.message;
        } else if (segue.identifier == "addMessageSegue") {
            localData.targetUserId = friendId;
            localData.editType = "append";
            localData.messageIndex = "-1";
        }
    }

    
    @IBAction func unwindWhenMessageAppended(segue: UIStoryboardSegue) {
        print("Segue is happening!");
    }
    
}
