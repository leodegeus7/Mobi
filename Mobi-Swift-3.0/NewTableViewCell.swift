//
//  NewTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/4/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class NewTableViewCell: UITableViewCell {

  
  @IBOutlet weak var labelDate: UILabel!
  @IBOutlet weak var labelTitle: UITextView!
  
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
      let colorAlpha = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.2)
      let viewSelected = UIView()
      viewSelected.backgroundColor = colorAlpha
      self.selectedBackgroundView = viewSelected
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
