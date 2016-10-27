//
//  AdsTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class AdsTableViewCell: UITableViewCell {

  @IBOutlet weak var adsButton: UIButton!
  
    override func awakeFromNib() {
        super.awakeFromNib()
      adsButton.backgroundColor = UIColor.brownColor()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
