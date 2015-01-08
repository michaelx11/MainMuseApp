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
}