//
//  ReviewTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

  @IBOutlet weak var textViewReview: UITextView!
  @IBOutlet weak var labelDate: UILabel!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var imageUser: UIImageView!
  
  @IBOutlet weak var imageStar1: UIImageView!
  
  @IBOutlet weak var imageStar5: UIImageView!
  @IBOutlet weak var imageStar4: UIImageView!
  @IBOutlet weak var imageStar3: UIImageView!
  @IBOutlet weak var imageStar2: UIImageView!
  
    var stars = [UIImageView]()
  
    override func awakeFromNib() {
        super.awakeFromNib()
      stars.append(imageStar1)
      stars.append(imageStar2)
      stars.append(imageStar3)
      stars.append(imageStar4)
      stars.append(imageStar5)
      
      for star in stars  {
        star.image = UIImage(named: "starOFF.png")
      }
      
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
