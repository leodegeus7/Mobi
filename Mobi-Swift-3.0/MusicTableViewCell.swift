//
//  MusicTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

  @IBOutlet weak var imageMusic: UIImageView!
  @IBOutlet weak var labelMusicName: UILabel!
  @IBOutlet weak var labelArtist: UILabel!

  @IBOutlet weak var buttonNLike: UIButton!
  @IBOutlet weak var butonLike: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  @IBAction func buttonNLike(sender: AnyObject) {
    buttonNLike.backgroundColor = UIColor(red: 228/255, green: 60/255, blue: 57/255, alpha: 0.7)
    butonLike.backgroundColor = UIColor(red: 255/255, green: 1, blue: 1, alpha: 1)
  }
  @IBAction func buttonLike(sender: AnyObject) {
    butonLike.backgroundColor = UIColor(red: 228/255, green: 60/255, blue: 57/255, alpha: 0.7)
    buttonNLike.backgroundColor = UIColor(red: 255/255, green: 1, blue: 1, alpha: 1)
  }
}
