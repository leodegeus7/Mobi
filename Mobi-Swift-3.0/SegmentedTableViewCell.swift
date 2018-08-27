//
//  SegmentedTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SegmentedTableViewCell: UITableViewCell {

  @IBOutlet weak var segmentedControl: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
