//
//  SecondInitialTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/15/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class InitialTableViewCell: UITableViewCell {

  @IBOutlet weak var imageBig: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelLocal: UILabel!
  @IBOutlet weak var imageSmallOne: UIImageView!
  @IBOutlet weak var imageSmallTwo: UIImageView!
  @IBOutlet weak var labelDescriptionOne: UILabel!
  @IBOutlet weak var labelDescriptionTwo: UILabel!
  
  
  @IBOutlet weak var widthTextOne: NSLayoutConstraint!
  @IBOutlet weak var widthTextTwo: NSLayoutConstraint!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
