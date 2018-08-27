//
//  VAdsInfo3TableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/15/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import UIKit

class VAdsInfo3TableViewCell: UITableViewCell {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var lat: UILabel!
  @IBOutlet weak var long: UILabel!
  @IBOutlet weak var descrip: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
