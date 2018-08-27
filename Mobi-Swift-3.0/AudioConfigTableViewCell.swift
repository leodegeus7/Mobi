//
//  AudioConfigTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class AudioConfigTableViewCell: UITableViewCell {
  
  @IBOutlet weak var labelAudio: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.withAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
