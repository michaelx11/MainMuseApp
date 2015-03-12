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
    
    var friendName : NSString!;
    var friendId : NSString!;
    var myId : NSString!;
    var myToken : NSString!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navItemView.title = "From: " + friendName;
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
            self.subjectLabel.text = localData.editingMessage.subject as NSString;
            self.textView.text = localData.editingMessage.body as NSString;
        })
        return;
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    }
    
    
}
