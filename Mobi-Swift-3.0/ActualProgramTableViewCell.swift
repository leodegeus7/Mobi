//
//  ActualProgramTableViewCell.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/27/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class ActualProgramTableViewCell: UITableViewCell {
  
  @IBOutlet weak var labelIndicatorGuests: UILabel!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var imagePerson: UIImageView!
  @IBOutlet weak var labelNamePerson: UILabel!
  @IBOutlet weak var labelGuests: UILabel!
  @IBOutlet weak var labelSecondName: UILabel!
  
  @IBOutlet weak var viewLocked: UIView!
  @IBOutlet weak var labelLocked: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    self.selectionStyle = .None

  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func lockView() {
    viewLocked.alpha = 0.8
    viewLocked.hidden = false
    labelLocked.text = ""
    labelGuests.text = "Convidados"
    labelName.text = "Sem programação da rádio"
    labelNamePerson.text = "Apresentador"
    labelSecondName.text = ""
    labelLocked.textColor = DataManager.sharedInstance.interfaceColor.color
    imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
    imagePerson.layer.borderColor = UIColor.blackColor().CGColor
    imagePerson.layer.borderWidth = 0
    let imageCD = UIImage(named: "logo-brancaAbert.png")
    var imageCDView = UIImageView(frame: imagePerson.frame)
    imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
    imagePerson.image = imageCDView.image
    imagePerson.tintColor = DataManager.sharedInstance.interfaceColor.color
  }
  
  func unlockView() {
    viewLocked.alpha = 0
    viewLocked.hidden = true
    
  }
  
}
