//
//  FirstNewTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class FirstNewTableViewCell: UITableViewCell {

  @IBOutlet weak var labelDate: UILabel!
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var textDescription: UITextView!
  @IBOutlet weak var imageDescription: UIImageView!
  

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
