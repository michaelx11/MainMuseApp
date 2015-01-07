//
//  AppLocalData.swift
//  MainMuse
//
//  Created by Michael Xu on 1/7/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation

class AppLocalData {
    var fullName : NSString!;
    var localId : NSString!;
    var accessToken : NSString!;
    var localEmail : NSString!;
    var localFriendCode : NSString!;
    var verified : Bool;
    
    init() {
        fullName = "";
        localId = "";
        accessToken = "";
        localEmail = "";
        localFriendCode = "";
        verified = false;
    }
}