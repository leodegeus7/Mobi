//
//  NoPostsTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/21/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class NoPostsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var labelTitle: UILabel!

  @IBOutlet weak var textViewDescription: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
