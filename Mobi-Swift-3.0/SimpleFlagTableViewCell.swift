//
//  SimpleFlagTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/29/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SimpleFlagTableViewCell: UITableViewCell {
  
  @IBOutlet weak var labelTitle: UILabel!
  @IBOutlet weak var flagIcon: UIButton!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    self.flagIcon.backgroundColor = UIColor.clear
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
