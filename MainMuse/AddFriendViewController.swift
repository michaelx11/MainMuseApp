//
//  AddFriendViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/6/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {

    @IBOutlet var myCodeLabel : UILabel!;
    @IBOutlet var textField : UITextField!;
    @IBOutlet var resultTextView : UITextView!;
    @IBOutlet var saveFriendButton : UIBarButtonItem!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard");
        self.view.addGestureRecognizer(tapRecognizer);
        myCodeLabel.text = myCodeLabel.text! + " " + localData.localFriendCode;
        saveFriendButton.action = "addFriend";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        textField.resignFirstResponder();
    }
    
    func addFriend() {
        var rawPath : String = "http://" + HOST + ":9988/addfriend?id=" + localData.localId + "&token=" + localData.appAccessToken + "&friendcode=" + textField.text;
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
            if (jsonResult["error"] != nil) {
                println(jsonResult["error"]);
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.resultTextView.text = jsonResult["name"] as NSString;
                })
            }
        })
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
