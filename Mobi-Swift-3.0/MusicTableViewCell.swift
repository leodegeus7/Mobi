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
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var viewLoading: UIView!
  @IBOutlet weak var viewWithMusic: UIView!
  @IBOutlet weak var viewWithoutMusic: UIView!
  @IBOutlet weak var buttonNLike: UIButton!
  @IBOutlet weak var buttonLike: UIButton!
  @IBOutlet weak var labelWithoutMusic: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.2)
    let viewSelected = UIView()
    viewSelected.backgroundColor = colorAlpha
    self.selectedBackgroundView = viewSelected
    imageMusic.backgroundColor = UIColor.clearColor()
    
//    var imageLike = UIImage(named: "like1.png")
//    imageLike = Util.imageResize(imageLike!, sizeChange: CGSize(width: 50, height: 50))
//    let imageLikeView = UIImageView(frame: buttonLike.frame)
//    buttonLike.setImage(imageLikeView.image, forState: .Normal)
//    
//    
//    let imageNLike = buttonNLike.imageView?.image
//    //UIImage(named: "dislike.png")
//    var imageNLikeView = UIImageView(frame: buttonNLike.frame)
//    imageNLikeView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageNLike!)
//    buttonNLike.setImage(imageNLikeView.image, forState: .Normal)

    
    
    
    if imageMusic.tintColor != DataManager.sharedInstance.interfaceColor.color {
      activityIndicator.color = DataManager.sharedInstance.interfaceColor.color
      let imageCD = UIImage(named: "logo-brancaAbert.png")
      var imageCDView = UIImageView(frame: imageMusic.frame)
      imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
      imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
      imageMusic.image = imageCDView.image
      imageMusic.alpha = 0.85
    }
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  
  
  func unlockContent() {
    viewLoading.alpha = 0
    viewWithoutMusic.alpha = 0
    viewWithMusic.alpha = 1
    imageMusic.alpha = 1
    buttonNLike.alpha = 1
    buttonLike.alpha = 1
    labelWithoutMusic.text = ""
  }
  
  func lockContent() {
    viewLoading.alpha = 0
    viewWithoutMusic.alpha = 0.8
    viewWithMusic.alpha = 0.6
    imageMusic.image = UIImage()
    imageMusic.backgroundColor = UIColor.clearColor()
    imageMusic.alpha = 0.6
    labelArtist.text = "Artista"
    labelMusicName.text = "Musica"
    buttonNLike.alpha = 0.6
    buttonLike.alpha = 0.6
    labelWithoutMusic.text = "Não há informação da música"
    labelWithoutMusic.textColor = DataManager.sharedInstance.interfaceColor.color
    //if imageMusic.tintColor != DataManager.sharedInstance.interfaceColor.color {
      //let imageCD = UIImage(named: "musicIcon.png")
    let imageCD = UIImage(named: "logo-brancaAbert.png")
      var imageCDView = UIImageView(frame: imageMusic.frame)
      imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
      imageMusic.image = imageCDView.image
      imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
    //}
  }
  
  func loadInfo() {
    lockContent()
    viewWithoutMusic.alpha = 0
    viewLoading.alpha = 0.8
  }
}
