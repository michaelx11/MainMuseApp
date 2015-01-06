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
    @IBOutlet var addFriendButton : UIButton!;
    
    var tableData : [String] = ["Michael Xu", "Minerva Zhou"];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section:    Int) -> Int {
        return tableData.count
    }
    
    var firstView = true;
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
//        let cell: UITableViewCell = FriendsTableViewCell();
        let cell: FriendsTableViewCell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath) as FriendsTableViewCell;
        
        let readButton : FriendButton = cell.contentView.viewWithTag(2) as FriendButton;
        
        if (indexPath.row % 2 == 0) {
            readButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal);
        } else {
            readButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal);
        }
        if (indexPath.row >= tableData.count) {
            return cell;
        }
        cell.textLabel?.text = tableData[indexPath.row] as String;
        readButton.friendName = tableData[indexPath.row] as String;
        /*
        cell.textLabel?.text = "Row #\(indexPath.row)"
        cell.detailTextLabel?.text = "Subtitle #\(indexPath.row)"

        var buttonView = UIButton();
        buttonView.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;
        buttonView.frame = CGRect(x: 300, y: 0, width: 50, height: 50);
//        var horizontalConstraint = NSLayoutConstraint(item: <#AnyObject#>, attribute: <#NSLayoutAttribute#>, relatedBy: <#NSLayoutRelation#>, toItem: <#AnyObject?#>, attribute: <#NSLayoutAttribute#>, multiplier: <#CGFloat#>, constant: <#CGFloat#>)
//        buttonView.addConstraint(NSLayoutConstraint.)
        buttonView.setTitle("Read!", forState : UIControlState.Normal);
        buttonView.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
        cell.addSubview(buttonView);
        */
        
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
