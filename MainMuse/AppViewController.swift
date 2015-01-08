//
//  AppViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {

    @IBOutlet var friendsTableView : UITableView!;
    @IBOutlet var addFriendButton : UIBarButtonItem!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        println("APP VIEW DID LOAD");
    }
    
    func obtainData() {
        getUserData(localData.localId, token: localData.appAccessToken);
    }
    
    override func viewWillAppear(animated: Bool) {
        obtainData();
    }
    
    func getUserData(id: NSString, token: NSString) {
        var rawPath : String = "http://" + HOST + ":9988/getuserdata?id=" + id + "&token=" + token;
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
                return;
            }
            if (jsonResult["error"] == nil) {
                localData.loadUserObject(jsonResult);
                dispatch_async(dispatch_get_main_queue(), {
                self.friendsTableView.reloadData();
                println(localData.friendsList.count);
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
    
    var firstView = true;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
//        let cell: UITableViewCell = FriendsTableViewCell();
        let cell: FriendsTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath) as FriendsTableViewCell;
        
        let readButton : FriendButton = cell.contentView.viewWithTag(2) as FriendButton;
        let progressBar : UIProgressView = cell.contentView.viewWithTag(3) as UIProgressView;
        

        if (indexPath.row >= localData.friendsList.count) {
            return cell;
        }
        
        println(localData.friendsList.count);
        let friend : FriendData = localData.friendsList[indexPath.row];
        cell.textLabel?.text = friend.friendName;
        readButton.friendName = friend.friendName;
        readButton.friendId = friend.friendId;
        
        println(friend.newMessage);
        if (friend.newMessage as Bool) {
            readButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal);
        } else {
            readButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal);
        }
        
        progressBar.progress = Float(friend.progress);
        
        if (firstView) {
            var yOffset : CGFloat = 0;
            
            if (tableView.contentSize.height > tableView.bounds.size.height) {
                yOffset = tableView.contentSize.height - tableView.bounds.size.height;
            }
            var bottom: CGPoint = CGPoint(x: 0, y: yOffset)
            tableView.setContentOffset(bottom, animated: false)
            firstView = false
        }
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (sender is FriendButton) {
            let uiButton : FriendButton = sender as FriendButton;
            if (segue.identifier == "readSegue") {
                let navController : UINavigationController = segue.destinationViewController as UINavigationController;
                let readerViewController : ReaderViewController = navController.topViewController as ReaderViewController;
                readerViewController.friendId = uiButton.friendId;
                readerViewController.friendName = uiButton.friendName;
                readerViewController.myToken = uiButton.myToken;
                readerViewController.myId = uiButton.myId;
            }
            
            if (segue.identifier == "writeSegue") {
                let navController : UINavigationController = segue.destinationViewController as UINavigationController;
                let messageListController : MessageListController = navController.topViewController as MessageListController;
                messageListController.friendId = uiButton.friendId;
                messageListController.friendName = uiButton.friendName;
                messageListController.myToken = uiButton.myToken;
                messageListController.myId = uiButton.myId;
            }
        }
    }
    

}
