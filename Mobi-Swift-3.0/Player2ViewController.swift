//
//  Player2ViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/4/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class Player2ViewController: UIViewController {
  
  @IBOutlet weak var imageLogo: UIImageView!
  @IBOutlet weak var labelName: UILabel!
  @IBOutlet weak var labelLocal: UILabel!
  @IBOutlet weak var buttonPlay: UIButton!
  @IBOutlet weak var buttonFav: UIButton!
  @IBOutlet weak var labelProgramName: UILabel!
  @IBOutlet weak var imagePerson: UIImageView!
  @IBOutlet weak var labelNamePerson: UILabel!
  @IBOutlet weak var labelGuests: UILabel!
  
  @IBOutlet weak var imageMusic: UIImageView!
  @IBOutlet weak var labelMusicName: UILabel!
  @IBOutlet weak var labelArtist: UILabel!
  
  @IBOutlet weak var buttonNLike: UIButton!
  @IBOutlet weak var butonLike: UIButton!
  
  @IBOutlet weak var segmentedControlProgram: UISegmentedControl!
  
  @IBOutlet weak var viewProgram: UIView!
  @IBOutlet weak var viewMusic: UIView!
  enum TypeSegmented {
    case Music
    case Program
  }
  
  var actualSegmented:TypeSegmented = .Music
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var tapCloseButtonActionHandler : (Void -> Void)?
  
  @IBOutlet weak var viewFirst: UIView!
  @IBOutlet weak var viewSeparator: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateInfoOfView()
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "heart.png"), forState: .Normal)
    } else {
      buttonFav.setImage(UIImage(named: "heartRed.png"), forState: .Normal)
    }
    let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(1)
    view.backgroundColor = colorAlpha
    viewFirst.backgroundColor = colorAlpha
    
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    let color = UIColor(red: components[0]-0.20, green: components[1]-0.20, blue: components[2]-0.20, alpha: 1)
    viewSeparator.backgroundColor = color
    segmentedControlProgram.tintColor = color
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(animated: Bool) {
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "heart.png"), forState: .Normal)
    } else {
      buttonFav.setImage(UIImage(named: "heartRedFilled.png"), forState: .Normal)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func toggle() {
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying() {
      StreamingRadioManager.sharedInstance.stop() //se clicar no botão e estiver tocando algo, o player para.
    } else {
      StreamingRadioManager.sharedInstance.playActualRadio() //se clicar no botão e não estiver tocando algo, o player começa.
    }
  }
  
  func updateInfoOfView() {
    imageLogo.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(StreamingRadioManager.sharedInstance.actualRadio.thumbnail)))
    
    imageLogo.layer.cornerRadius = imageLogo.bounds.height / 6
    imageLogo.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.CGColor
    imageLogo.layer.backgroundColor = UIColor.whiteColor().CGColor
    imageLogo.layer.borderWidth = 1
    
    labelName.text = StreamingRadioManager.sharedInstance.actualRadio.name
    
    if let _ = StreamingRadioManager.sharedInstance.actualRadio.address {
      labelLocal.text = StreamingRadioManager.sharedInstance.actualRadio.address.formattedLocal
    }
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying()  {
      //so mostra o play para a radio que esta tocando
      buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
    } else {
      buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
    }
    
    labelMusicName.text = "Happy"
    labelArtist.text = "Pharell Willians"
    buttonNLike.backgroundColor = UIColor.clearColor()
    butonLike.backgroundColor = UIColor.clearColor()
    imageMusic.image = UIImage(named: "happy.jpg")
    
    labelProgramName.text = "Programa da Manha"
    imagePerson.image = UIImage(named: "happy.jpg")
    imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
    imagePerson.layer.borderColor = UIColor.blackColor().CGColor
    imagePerson.layer.borderWidth = 0
    imagePerson.clipsToBounds = true
    labelNamePerson.text = "Marcos"
    labelGuests.text = "Toninho e Fulanhinho de tal"
    
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    let color = ColorRealm(name: 3, red: components[0]-0.5, green: components[1]-0.5, blue: components[2]-0.5, alpha: 1)
    
    buttonPlay.backgroundColor = color.color
    buttonPlay.layer.cornerRadius = buttonPlay.bounds.height / 2
    buttonPlay.clipsToBounds = true
    
    buttonFav.backgroundColor = color.color
    buttonFav.layer.cornerRadius = buttonFav.bounds.height / 2
    buttonFav.clipsToBounds = true
  }
  
  @IBAction func segmentedChanged(sender: AnyObject) {
    switch segmentedControlProgram.selectedSegmentIndex {
    case 0:
      viewMusic.hidden = false
      viewProgram.hidden = true
      actualSegmented = .Music
    case 1:
      viewMusic.hidden = true
      viewProgram.hidden = false
      actualSegmented = .Program
    default:
      break
    }
  }
  
  @IBAction func buttonPlayTapped(sender: AnyObject) {
    toggle()
    StreamingRadioManager.sharedInstance.sendNotification()
  }
  
  @IBAction func buttonFavTapped(sender: AnyObject) {
    let manager = RequestManager()
    if StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "heart.png"), forState: .Normal)
      
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(false)
      manager.deleteFavRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (result) in
      })
    } else {
      buttonFav.setImage(UIImage(named: "heartRed.png"), forState: .Normal)
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(true)
      manager.favRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (resultFav) in
      })
    }
    
  }
  
  func updateIcons() {
    if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
      if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(StreamingRadioManager.sharedInstance.actualRadio)) {
        buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
      } else {
        buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
      }
    } else {
      buttonPlay.setImage(UIImage(named: "play.png"), forState: .Normal)
    }
  }
  
  @IBAction func hidePlayerAction(sender: AnyObject) {
    DataManager.sharedInstance.miniPlayerView.hidePlayer()
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
