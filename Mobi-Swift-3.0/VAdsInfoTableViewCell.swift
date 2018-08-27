//
//  AdsInfoTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 2/9/17.
//  Copyright © 2017 Access Mobile. All rights reserved.
//

import UIKit

class VAdsInfoTableViewCell: UITableViewCell {

  @IBOutlet weak var nameU: UILabel!
  @IBOutlet weak var imageU: UIImageView!

  @IBOutlet weak var firstU: UILabel!
  @IBOutlet weak var firstU2: UILabel!
  @IBOutlet weak var secondU: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        firstU.text = ""
        secondU.text = ""
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
