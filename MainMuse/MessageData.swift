//
//  MessageData.swift
//  MainMuse
//
//  Created by Michael Xu on 1/8/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import Foundation

class MessageData {
    var subject : String!;
    var body : String!;
    var index : String!;
    
    init() {
        subject = "";
        body = "";
        index = "";
    }
    
    func toJsonString() -> String {
//        return "{\"body\" : \"\(body)\", \"subject\": \"\(subject)\"}";
        var dict : NSDictionary = NSMutableDictionary();
        dict.setValue(subject, forKey: "subject");
        dict.setValue(body, forKey: "body");
        var bytes = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.allZeros, error: nil);
        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(bytes!, options: nil, error: nil);
        return NSString(data: bytes!, encoding: NSUTF8StringEncoding)! as String;
    }
}