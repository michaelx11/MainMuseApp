//
//  AppLocalData.swift
//  MainMuse
//
//  Created by Michael Xu on 1/7/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation

var HOST : NSString = "localhost";

class AppLocalData {
    var fullName : NSString!;
    var localId : NSString!;
    var accessToken : NSString!;
    var appAccessToken : NSString!;
    var localEmail : NSString!;
    var localFriendCode : NSString!;
    var verified : Bool;
    
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
    
    func loadUserObject(userObj: NSDictionary) {
        localFriendCode = userObj["friendcode"] as NSString;
        if (userObj["queues"] != nil) {
            friendsList = [];
            let queues : NSDictionary = userObj["queues"] as NSDictionary;
            for (id, obj) in queues {
                let syncObject : NSDictionary = obj["sync"] as NSDictionary;
                println(syncObject);
                if (syncObject["status"] as NSString != "accepted") {
                    continue;
                }
                
                var tempData = FriendData();
                tempData.friendId = id as NSString;
                tempData.friendName = syncObject["name"] as NSString;
                var timestamp : NSInteger = syncObject["timestamp"] as NSInteger;
                var interval : NSInteger = syncObject["interval"] as NSInteger;
                var currentTime : Double = (NSDate().timeIntervalSince1970);
                var currentTimeInt : NSInteger = NSInteger(currentTime * 1000.0);
                tempData.newMessage = (currentTimeInt - timestamp >= interval);
                tempData.progress = (Double(currentTimeInt - timestamp)) / (Double(interval));
                if (tempData.progress > 1.0) {
                    tempData.progress = 1.0;
                }
                friendsList.append(tempData);
            }
        }
    }
}