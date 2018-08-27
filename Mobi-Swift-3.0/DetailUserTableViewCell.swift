//
//  DetailUserTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class DetailUserTableViewCell: UITableViewCell {

  @IBOutlet weak var imageUser: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelLocal: UILabel!
  @IBOutlet weak var buttonFollowers: UIButton!
  @IBOutlet weak var buttonFollowing: UIButton!
  @IBOutlet weak var labelFollowers: UILabel!
  @IBOutlet weak var labelFollowing: UILabel!
  @IBOutlet weak var labelIndicatorFollowers: UILabel!
  @IBOutlet weak var labelIndicatorFollowing: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
