//
//  MessageListController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class MessageReaderListController: UIViewController {
    
    var friendName : String!;
    var friendId : String!;
    var myId : String!;
    var myToken : String!;
    
    var messageList : [MessageData] = [];
    
    let localData : AppLocalData = AppLocalData.sharedInstance
    
    @IBOutlet var messageTable : UITableView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // otherwise after read -> back, there is space at the top
        self.automaticallyAdjustsScrollViewInsets = false;
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated : Bool) {
        self.navigationItem.title = friendName;
        getMessages();
    }
    
    func getMessages() {
        var rawPath : String = "http://\(HOST)/getmessagesfrom?id=\(localData.localId)&token=\(localData.appAccessToken)&sourceid=\(friendId)";
        let urlPath : String = rawPath.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!;
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
                let messages : NSDictionary = jsonResult["messages"] as! NSDictionary;
                var keys : [NSInteger] = [];
                for (index, message) in messages {
                    keys.append(index.integerValue);
                }
                let sortedKeys = keys.sorted(>).map({"\($0)"});
                
                self.messageList = [];
                for index in sortedKeys {
                    var message : NSDictionary = messages[index] as! NSDictionary;
                    var tempMessage = MessageData();
                    tempMessage.index = index;
                    tempMessage.subject = message["subject"] as! String;
                    tempMessage.body = message["body"] as! String;
                    self.messageList.append(tempMessage);
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
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! UITableViewCell;
        
        let messageLabel : UILabel = cell.contentView.viewWithTag(1) as! UILabel;
        let readButton : FriendButton = cell.contentView.viewWithTag(2) as! FriendButton;
        
        if (indexPath.row >= messageList.count) {
            return cell;
        }
        
        let message : MessageData = messageList[indexPath.row];
        messageLabel.text = "\(message.index). \(message.subject)";
        readButton.index = message.index;
        readButton.message = message;
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "readMessageSegue") {
            let uiButton : FriendButton = sender as! FriendButton;
            let readerViewController : ReaderViewController = segue.destinationViewController as! ReaderViewController;
            readerViewController.friendId = self.friendId;
            readerViewController.friendName = self.friendName;
            readerViewController.myToken = self.myToken;
            readerViewController.myId = self.myId;
            readerViewController.isLandingPage = false;
            localData.messageIndex = uiButton.index;
            localData.editingMessage = uiButton.message;
        }
    }
    
    
    @IBAction func unwindWhenMessageAppended(segue: UIStoryboardSegue) {
        println("Segue is happening!");
    }
    
}
