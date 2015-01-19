//
//  MessageListController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class MessageListController: UIViewController {

    var friendName : NSString!;
    var friendId : NSString!;
    var myId : NSString!;
    var myToken : NSString!;
    
    var messageList : [MessageData] = [];
    
    @IBOutlet var messageTable : UITableView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        var rawPath : String = "http://\(HOST)/getmessagelist?id=\(localData.localId)&token=\(localData.appAccessToken)&targetid=\(friendId)";
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
            
            var jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                return;
            }
            if (jsonResult["error"] != nil) {
                println(jsonResult["error"]);
            } else {
                let messages : NSDictionary = jsonResult["messages"] as NSDictionary;
                var keys : [NSInteger] = [];
                for (index, message) in messages {
                    keys.append((index as NSString).integerValue);
                }
                let sortedKeys = keys.sorted(<).map({"\($0)"});
                
                self.messageList = [];
                for index in sortedKeys {
                    var message : NSDictionary = messages[index] as NSDictionary;
                    var tempMessage = MessageData();
                    tempMessage.index = index as NSString;
                    tempMessage.subject = message["subject"] as NSString;
                    tempMessage.body = message["body"] as NSString;
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
        println("Count is \(messageList.count)");
        return messageList.count
    }
    
    var firstView = true;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as UITableViewCell;
        
        let messageLabel : UILabel = cell.contentView.viewWithTag(1) as UILabel;
        let editButton : FriendButton = cell.contentView.viewWithTag(2) as FriendButton;
        
        
        if (indexPath.row >= messageList.count) {
            return cell;
        }
        
        if (indexPath.row == 0) {
            editButton.tintColor = UIColor.grayColor();
//            cell.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.8, alpha: 0.5);
//            cell.backgroundColor = UIColor(red: 178, green: 190, blue: 181, alpha: 1.0);
//            cell.backgroundColor = UIColor.blueColor();
        }
        
        
        let message : MessageData = messageList[indexPath.row];
        messageLabel.text = "\(message.index). \(message.subject)";
        editButton.index = message.index;
        editButton.message = message;
        
        /*
        if (firstView) {
            var yOffset : CGFloat = 0;
            
            if (tableView.contentSize.height > tableView.bounds.size.height) {
                yOffset = tableView.contentSize.height - tableView.bounds.size.height;
            }
            var bottom: CGPoint = CGPoint(x: 0, y: yOffset)
            tableView.setContentOffset(bottom, animated: false)
            firstView = false
        }
        */
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editMessageSegue") {
            let senderButton : FriendButton = sender as FriendButton;
            localData.targetUserId = friendId;
            localData.editType = "edit";
            localData.messageIndex = senderButton.index;
            localData.editingMessage = senderButton.message;
        } else if (segue.identifier == "addMessageSegue") {
            localData.targetUserId = friendId;
            localData.editType = "append";
            localData.messageIndex = "-1";
        }
    }

    
    @IBAction func unwindWhenMessageAppended(segue: UIStoryboardSegue) {
        println("Segue is happening!");
    }
    
}
