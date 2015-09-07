//
//  AppViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {

    @IBOutlet var friendsTableView : UITableView!
    @IBOutlet var addFriendButton : UIBarButtonItem!
    
    var refreshControl : UIRefreshControl!
    var localData : AppLocalData = AppLocalData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged);
        friendsTableView.addSubview(refreshControl);
    }
    
    func obtainData() {
        getUserData(localData.localId, token: localData.appAccessToken);
    }
    
    override func viewWillAppear(animated: Bool) {
        obtainData();
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        obtainData();
//        refreshControl.endRefreshing();
    }
    
    func getUserData(id: String, token: String) {
        var rawPath : String = "http://" + (HOST as String) + "/getuserdata?id=" + id + "&token=" + (token as String);
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
            
            var jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
                return;
            }
            if (jsonResult["error"] == nil) {
                self.localData.loadUserObject(jsonResult);
                dispatch_async(dispatch_get_main_queue(), {
                    self.friendsTableView.reloadData();
                    self.refreshControl.endRefreshing();
                });
            } else {
                println(jsonResult["error"]);
            }
        })
        
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return localData.friendsList.count
    }
    
    func convertProgressToString(progress : Float) -> String {
        let remaining : Float = 1.0 - progress;
        if (remaining >= 0.04999) {
            return "\(Int(remaining * 20.0 + 0.5))h";
        } else {
            return "\(Int(remaining / 0.05 * 60.0 + 0.5))m";
        }
    }
    
    var firstView = true;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FriendsTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath) as! FriendsTableViewCell;
        
        let writeButton : FriendButton = cell.contentView.viewWithTag(1) as! FriendButton;
        let readButton : FriendButton = cell.contentView.viewWithTag(2) as! FriendButton;
        let progressBar : UIProgressView = cell.contentView.viewWithTag(3) as! UIProgressView;
        let progressLabel : UILabel = cell.contentView.viewWithTag(4) as! UILabel;
        let nameLabel : UILabel = cell.contentView.viewWithTag(5) as! UILabel;

        if (indexPath.row >= localData.friendsList.count) {
            return cell;
        }
        
        let friend : FriendData = localData.friendsList[indexPath.row];
        nameLabel.text = friend.friendName;
        readButton.friendName = friend.friendName;
        readButton.friendId = friend.friendId;
        writeButton.friendName = friend.friendName;
        writeButton.friendId = friend.friendId;
        
        if (friend.newMessage as Bool) {
            readButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal);
        } else {
            readButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal);
        }
        
        progressBar.progress = Float(friend.progress);
        progressLabel.text = convertProgressToString(progressBar.progress);
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (sender is FriendButton) {
            let uiButton : FriendButton = sender as! FriendButton;
            if (segue.identifier == "readSegue") {
                let navController : UINavigationController = segue.destinationViewController as! UINavigationController;
                let readerViewController : ReaderViewController = navController.topViewController as! ReaderViewController;
                readerViewController.friendId = uiButton.friendId;
                readerViewController.friendName = uiButton.friendName;
                readerViewController.myToken = uiButton.myToken;
                readerViewController.myId = uiButton.myId;
            }
            
            if (segue.identifier == "writeSegue") {
                let navController : UINavigationController = segue.destinationViewController as! UINavigationController;
                let messageListController : MessageListController = navController.topViewController as! MessageListController;
                messageListController.friendId = uiButton.friendId;
                messageListController.friendName = uiButton.friendName;
                messageListController.myToken = uiButton.myToken;
                messageListController.myId = uiButton.myId;
            }
        }
    }
    

}
