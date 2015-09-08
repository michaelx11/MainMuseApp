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
    
    // Initialize from base64 encoded data
    init?(messageIndex : String, base64 : String) {
        if let decodedData : NSData = NSData(base64EncodedString: base64, options: nil) {
            var err : NSError?
            var jsonResult : NSDictionary = NSJSONSerialization.JSONObjectWithData(decodedData, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if(err == nil) {
                index = messageIndex;
                if let subjectString = jsonResult["subject"] as? String {
                    if let bodyString = jsonResult["body"] as? String {
                        subject = subjectString
                        body = bodyString
                        return
                    }
                }
            }
        }
        return nil
    }

    func toJsonString() -> String {
        var dict : NSDictionary = NSMutableDictionary();
        dict.setValue(subject, forKey: "subject");
        dict.setValue(body, forKey: "body");
        var bytes = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.allZeros, error: nil);
//        var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(bytes!, options: nil, error: nil);
//        return json?.base64EncodedStringWithOptions(0);
//        return NSString(data: bytes!, encoding: NSUTF8StringEncoding)! as String;
        if let base64String = bytes?.base64EncodedStringWithOptions(nil) {
            return base64String as String
        } else {
            // {"subject": "placeholder", "body": "error processing"}
            return "eyJzdWJqZWN0IjoicGxhY2Vob2xkZXIiLCAiYm9keSI6ImVycm9yIHByb2Nlc3NpbmcifQ=="
        }
    }
}