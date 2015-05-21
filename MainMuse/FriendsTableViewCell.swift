//
//  FriendsTableViewCell.swift
//  MainMuse
//
//  Created by Michael Xu on 1/4/15.
//  Copyright (c) 2015 Michael Xu. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    var friendName : String!;
    var friendId : String!;
    var myId : String!;
    var myToken : String!;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
