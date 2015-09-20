//
//  MessageListController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class MessageReaderListController: UIViewController, UITableViewDelegate {
    
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
        let rawPath : String = "http://\(HOST)/getmessagesfrom?id=\(localData.localId)&token=\(localData.appAccessToken)&sourceid=\(friendId)";
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
                let sortedKeys = keys.sort(>).map({"\($0)"});
                
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("SELECTED")
        dispatch_async(dispatch_get_main_queue(), {
            self.localData.messageIndex = self.messageList[indexPath.row].index
            self.localData.editingMessage = self.messageList[indexPath.row]
            self.performSegueWithIdentifier("readMessageSegue", sender: self)
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return messageList.count
    }
    
    var firstView = true;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) ;
        
        let messageLabel : UILabel = cell.contentView.viewWithTag(1) as! UILabel;
        
        if (indexPath.row >= messageList.count) {
            return cell;
        }
        
        let message : MessageData = messageList[indexPath.row];
        messageLabel.text = "\(message.index). \(message.subject)";
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "readMessageSegue") {
            let readerViewController : ReaderViewController = segue.destinationViewController as! ReaderViewController;
            readerViewController.friendId = self.friendId;
            readerViewController.friendName = self.friendName;
            readerViewController.myToken = self.myToken;
            readerViewController.myId = self.myId;
            readerViewController.isLandingPage = false;
        }
    }
    
    
    @IBAction func unwindWhenMessageAppended(segue: UIStoryboardSegue) {
        print("Segue is happening!");
    }
    
}
