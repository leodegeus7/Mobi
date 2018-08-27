//
//  NormalProgramTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/13/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class NormalProgramTableViewCell: UITableViewCell {
  
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var imagePerson: UIImageView!
  @IBOutlet weak var labelNamePerson: UILabel!
  
  
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
