//
//  WallTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class WallTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textViewWall: UITextView!
  @IBOutlet weak var labelDate: UILabel!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var imageUser: UIImageView!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
