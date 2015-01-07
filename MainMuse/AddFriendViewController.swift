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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard");
        self.view.addGestureRecognizer(tapRecognizer);
        myCodeLabel.text = myCodeLabel.text! + " " + localData.localFriendCode;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        textField.resignFirstResponder();
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
