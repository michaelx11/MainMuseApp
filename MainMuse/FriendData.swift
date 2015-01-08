//
//  FriendData.swift
//  MainMuse
//
//  Created by Michael Xu on 1/7/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation

class FriendData {
    var friendId : NSString!;
    var friendName : NSString!;
    var newMessage : Bool!;
    var progress : Double; // out of 1.0
    
    init() {
        friendId = "";
        friendName = "";
        newMessage = false;
        progress = 0;
    }
}
