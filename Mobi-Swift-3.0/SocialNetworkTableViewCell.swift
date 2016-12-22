//
//  SocialNetworkTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/28/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SocialNetworkTableViewCell: UITableViewCell {

  @IBOutlet weak var buttonFace: UIButton!
  @IBOutlet weak var buttonInsta: UIButton!
  @IBOutlet weak var buttonTwitter: UIButton!
  @IBOutlet weak var buttonWhats: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}