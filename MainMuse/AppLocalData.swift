//
//  AppLocalData.swift
//  MainMuse
//
//  Created by Michael Xu on 1/7/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation

var HOST : String = "view.ninja";

class AppLocalData {
    var fullName : String!;
    var localId : String!;
    var accessToken : String!; // Facebook access token
    var appAccessToken : String!; // Access token for my server
    var localEmail : String!;
    var localFriendCode : String!;
    var verified : Bool;
    
    // This is for use by the message editor
    var targetUserId : String!;
    var editType : String!; // Either "edit" or "append"
    var messageIndex : String!; // The index or key of the message
    var editingMessage : MessageData!; // If it's editing, the current state of the message
    
    var friendsList : [FriendData];
    
    init() {
        fullName = "";
        localId = "";
        accessToken = "";
        localEmail = "";
        localFriendCode = "";
        verified = false;
        friendsList = [];
    }

    func sortUserFunc(a : FriendData, b : FriendData) -> Bool {
        return (a.friendName.compare(b.friendName)) == NSComparisonResult.OrderedAscending;
    }
    
    func loadUserObject(userObj: NSDictionary) {
        localFriendCode = userObj["friendcode"] as! String;
        if (userObj["queues"] != nil) {
            friendsList = [];
            let queues : NSDictionary = userObj["queues"] as! NSDictionary;
            for (id, obj) in queues {
                let syncObject : NSDictionary = obj["sync"] as! NSDictionary;
                println(syncObject);
                if (syncObject["status"] as! String != "accepted") {
                    continue;
                }
                
                var tempData = FriendData();
                tempData.friendId = id as! NSString as String;
                tempData.friendName = syncObject["name"] as! String;
                let timestampObj: AnyObject? = syncObject["timestamp"];
                let intervalObj: AnyObject? = syncObject["interval"];
                var timestamp : Int64 = timestampObj!.longLongValue;
                var interval : Int64 = intervalObj!.longLongValue;
                var head : NSInteger = syncObject["head"] as! NSInteger;
                var tail : NSInteger = syncObject["tail"] as! NSInteger;
                var currentTime : Double = (NSDate().timeIntervalSince1970);
                var currentTimeInt : Int64 = Int64(currentTime * 1000.0);
                
                tempData.newMessage = (currentTimeInt - Int64(timestamp) >= Int64(interval)) && (head < tail);
                tempData.progress = (Double(currentTimeInt - timestamp)) / (Double(interval));
                if (tempData.progress > 1.0) {
                    tempData.progress = 1.0;
                }
                friendsList.append(tempData);
            }
            friendsList.sort(sortUserFunc);
        }
    }
}