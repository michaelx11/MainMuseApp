//
//  MessageData.swift
//  MainMuse
//
//  Created by Michael Xu on 1/8/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation

class MessageData {
    var subject : NSString!;
    var body : NSString!;
    var index : NSString!;
    
    init() {
        subject = "";
        body = "";
        index = "";
    }
    
    func toJsonString() -> NSString {
        return "{\"body\" : \"\(body)\", \"subject\": \"\(subject)\"}";
//        var dict : NSDictionary = NSMutableDictionary();
//        dict.setValue(subject, forKey: "subject");
//        dict.setValue(body, forKey: "body");
//        var bytes = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.allZeros, error: nil);
//        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(bytes!, options: nil, error: nil);
//        return json as NSString;
    }
}