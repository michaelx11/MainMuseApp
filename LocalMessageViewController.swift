//
//  ReaderViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/5/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class LocalMessageViewController: UIViewController {
    
    @IBOutlet var subjectLabel : UILabel!;
    @IBOutlet var navItemView : UINavigationItem!;
    @IBOutlet var textView : UITextView!;
    
    var friendName : String!;
    var friendId : String!;
    var myId : String!;
    var myToken : String!;
    
    var localData : AppLocalData = AppLocalData.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navItemView.title = "From: " + String(friendName);
    }
    
    override func viewWillAppear(animated: Bool) {
        getMessage();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessage() {
        dispatch_async(dispatch_get_main_queue(), {
            self.subjectLabel.text = self.localData.editingMessage.subject;
            self.textView.text = self.localData.editingMessage.body;
        })
        return;
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }
    
    
}
