//
//  ReaderViewController.swift
//  MainMuse
//
//  Created by Michael Xu on 1/5/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class ReaderViewController: UIViewController {

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
