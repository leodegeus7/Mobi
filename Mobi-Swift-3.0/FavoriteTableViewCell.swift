//
//  FavoriteTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/18/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
  
  @IBOutlet weak var imageBig: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelLocal: UILabel!
  @IBOutlet weak var imageSmallOne: UIImageView!
  @IBOutlet weak var labelDescriptionOne: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
