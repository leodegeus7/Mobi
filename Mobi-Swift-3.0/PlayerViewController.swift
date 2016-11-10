//
//  Player2ViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/4/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
  
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
  @IBOutlet weak var imageIndicatorDown: UIButton!
  
  @IBOutlet weak var labelWithoutMusic: UILabel!
  @IBOutlet weak var viewWithoutMusic: UIView!
  @IBOutlet weak var viewLoading: UIView!
  @IBOutlet weak var viewProgram: UIView!
  @IBOutlet weak var viewMusic: UIView!
  @IBOutlet weak var buttonDetailRadio: UIButton!
  
  @IBOutlet weak var buttonAdvertisement: UIButton!
  
  enum TypeSegmented {
    case Music
    case Program
  }
  
  var actualSegmented:TypeSegmented = .Music
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var tapCloseButtonActionHandler : (Void -> Void)?
  
  @IBOutlet weak var contraintsPropFirstView: NSLayoutConstraint!
  
  var colorBlack : UIColor!
  var colorWhite : UIColor!
  
  var gracenote:GracenoteManager!
  
  @IBOutlet weak var viewFirst: UIView!
  @IBOutlet weak var viewSeparator: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let screenSize:CGRect = UIScreen.mainScreen().bounds
    let screenHeigh = screenSize.height
    
    if screenHeigh > 510 {
    
      let newHeight = self.view.frame.size.height * 0.65
      contraintsPropFirstView.constant = newHeight
    } else {
      let newHeight = self.view.frame.size.height * 0.45
      contraintsPropFirstView.constant = newHeight
    }
    
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "love1.png"), forState: .Normal)
    } else {
      buttonFav.setImage(UIImage(named: "love2.png"), forState: .Normal)
    }
    
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)

    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 1).color
    view.backgroundColor = colorWhite
    
    buttonDetailRadio.backgroundColor = UIColor.clearColor()
    viewSeparator.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    segmentedControlProgram.tintColor = DataManager.sharedInstance.interfaceColor.color
    updateInfoOfView()
    segmentedChanged(self)
    let colorWhite2 =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 0.2).color
    self.buttonAdvertisement.backgroundColor = colorWhite2
    self.buttonAdvertisement.setBackgroundImage(UIImage(named: "anuncio3.png"), forState: .Normal)
    AdsManager.sharedInstance.setAdvertisement(.PlayerScreen, completion: { (resultAd) in
      dispatch_async(dispatch_get_main_queue()) {
        if let imageAd = resultAd.image {
          let imageView = UIImageView(frame: self.buttonAdvertisement.frame)
          imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
          self.buttonAdvertisement.setBackgroundImage(imageView.image, forState: .Normal)
        }
      }
    })
    
    


    imageIndicatorDown.backgroundColor = UIColor.clearColor()
    
    viewSeparator.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    segmentedControlProgram.tintColor = DataManager.sharedInstance.interfaceColor.color


    
  }
  
  override func viewDidLayoutSubviews() {
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 1).color
    viewFirst.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: viewFirst.frame, andColors: [colorWhite,colorBlack])
    view.backgroundColor = colorWhite
    let colorWhite2 =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 0.2).color
    self.buttonAdvertisement.backgroundColor = colorWhite2
  }
  

  
  override func viewWillAppear(animated: Bool) {
    view.backgroundColor = colorWhite
  
    imageIndicatorDown.backgroundColor = UIColor.clearColor()
    
    viewSeparator.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    segmentedControlProgram.tintColor = DataManager.sharedInstance.interfaceColor.color
    updateInfoOfView()
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "love1.png"), forState: .Normal)
    } else {
      buttonFav.setImage(UIImage(named: "love2.png"), forState: .Normal)
    }
    setButtonMusicType(DataManager.sharedInstance.musicInExecution)
      
    
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
    imageLogo.layer.borderColor = colorBlack.CGColor
    imageLogo.layer.borderWidth = 0
    imageLogo.clipsToBounds = true
    labelName.text = StreamingRadioManager.sharedInstance.actualRadio.name.uppercaseString
    labelName.textColor = UIColor.whiteColor()
    if let _ = StreamingRadioManager.sharedInstance.actualRadio.address {
      labelLocal.text = StreamingRadioManager.sharedInstance.actualRadio.address.formattedLocal.uppercaseString
      labelLocal.textColor = UIColor.whiteColor()
    }
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying()  {
      //so mostra o play para a radio que esta tocando
      buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
    } else {
      buttonPlay.setImage(UIImage(named: "play1.png"), forState: .Normal)
    }
    
    updateInterfaceWithGracenote()
    
    labelProgramName.text = "Programa da Manha"
    imagePerson.image = UIImage(named: "logo-pretaAbert.png")
    imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
    imagePerson.layer.borderColor = UIColor.blackColor().CGColor
    imagePerson.layer.borderWidth = 0
    imagePerson.clipsToBounds = true
    labelNamePerson.text = "Marcos"
    labelGuests.text = "Toninho e Fulanhinho de tal"
    
    
    buttonPlay.backgroundColor = UIColor.clearColor()
    
    
    buttonFav.backgroundColor = UIColor.clearColor()
    
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
      buttonFav.setImage(UIImage(named: "love1.png"), forState: .Normal)
      
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(false)
      manager.deleteFavRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (result) in
      })
    } else {
      buttonFav.setImage(UIImage(named: "love2.png"), forState: .Normal)
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(true)
      manager.favRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (resultFav) in
      })
    }
    StreamingRadioManager.sharedInstance.sendNotification()
    
    
  }
  
  func updateIcons() {
    if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
      if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(StreamingRadioManager.sharedInstance.actualRadio)) {
        buttonPlay.setImage(UIImage(named: "pause.png"), forState: .Normal)
      } else {
        buttonPlay.setImage(UIImage(named: "play1.png"), forState: .Normal)
      }
    } else {
      buttonPlay.setImage(UIImage(named: "play1.png"), forState: .Normal)
    }
  }
  
  @IBAction func hidePlayerAction(sender: AnyObject) {
    DataManager.sharedInstance.miniPlayerView.hidePlayer()
  }
  

  
  func updateInterfaceWithGracenote() {
    loadingMusicView()
    if let _ = DataManager.sharedInstance.musicInExecution.name {
      if DataManager.sharedInstance.musicInExecution.isMusicOld() {
        requestGracenote({ (result) in
          if result.boolVar {
            self.updateMusicViewWithMusic(DataManager.sharedInstance.musicInExecution, gracenote: result)
          } else {
            self.lockMusicView()
          }
        })
      } else {
        if let gracenoteOptional = gracenote {
          updateMusicViewWithMusic(DataManager.sharedInstance.musicInExecution, gracenote: gracenoteOptional)
        }
      }
    } else {
      requestGracenote({ (result) in
        if result.boolVar {
            self.updateMusicViewWithMusic(DataManager.sharedInstance.musicInExecution, gracenote: result)
        } else {
          self.lockMusicView()
        }
      })
    }
  }
  
  func requestGracenote(completion: (result: GracenoteManager) -> Void) {
    if let audioChannel = StreamingRadioManager.sharedInstance.actualRadio.audioChannels.first {
      if audioChannel.existRdsLink {
        let rdsRequest = RequestManager()
        rdsRequest.downloadRdsInfo((StreamingRadioManager.sharedInstance.actualRadio.audioChannels.first?.linkRds.link)!) { (result) in
          if let resultTest = result[true] {
            if resultTest.existData {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let gracenote = GracenoteManager(bool: true)
                self.gracenote = gracenote
                gracenote.findMatch("", trackTitle: resultTest.title, albumArtistName: resultTest.artist, trackArtistName: "", composerName: "", completion: { (resultGracenote) in
                  dispatch_async(dispatch_get_main_queue(), {
                    DataManager.sharedInstance.musicInExecution = resultGracenote
                    if self.actualSegmented == .Music {
                      completion(result: gracenote)
                    }
                  })
                })
              })
              
            } else {
              completion(result: GracenoteManager())
            }
          } else {
            completion(result: GracenoteManager())
          }
        }
      } else {
        completion(result: GracenoteManager())
      }
    } else {
      completion(result: GracenoteManager())
    }
    
  }
  
  func updateMusicViewWithMusic(music:Music,gracenote:GracenoteManager) {
    if let musicName = DataManager.sharedInstance.musicInExecution.name  {
      viewWithoutMusic.hidden = true
      viewWithoutMusic.alpha = 0
      labelMusicName.text = musicName
      labelArtist.text = DataManager.sharedInstance.musicInExecution.composer
      buttonNLike.backgroundColor = UIColor.clearColor()
      butonLike.backgroundColor = UIColor.clearColor()
      if music.coverArt != ""{
        gracenote.downloadImageArt(music.coverArt, completion: { (resultImg) in
          dispatch_async(dispatch_get_main_queue()) {
            self.imageMusic.image = resultImg
          }
          
        })
      }
      setButtonMusicType(DataManager.sharedInstance.musicInExecution)
      viewLoading.alpha = 0
      viewWithoutMusic.alpha = 0
      viewMusic.alpha = 1
      imageMusic.alpha = 1
      buttonNLike.alpha = 1
      butonLike.alpha = 1
      labelWithoutMusic.text = ""
    } else {
      lockMusicView()
    }
  }
  
  func setButtonMusicType(music:Music) {
    if music.isPositive {
      butonLike.alpha = 1
      buttonNLike.alpha = 0.3
    }
    if music.isNegative {
      butonLike.alpha = 0.3
      buttonNLike.alpha = 1
    }
  }
  
  func loadingMusicView() {
    buttonNLike.backgroundColor = UIColor.clearColor()
    butonLike.backgroundColor = UIColor.clearColor()
    viewMusic.alpha = 0.8
    imageMusic.image = UIImage()
    imageMusic.backgroundColor = UIColor.clearColor()
    imageMusic.alpha = 0.6
    labelArtist.text = "Artista"
    labelMusicName.text = "Musica"
    buttonNLike.alpha = 0.6
    butonLike.alpha = 0.6
    labelWithoutMusic.text = "Não há informação da música"
    labelWithoutMusic.textColor = DataManager.sharedInstance.interfaceColor.color
    let imageCD = UIImage(named: "musicIcon.png")
    var imageCDView = UIImageView(frame: imageMusic.frame)
    imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
    imageMusic.image = imageCDView.image
    imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
    viewWithoutMusic.alpha = 0
    viewLoading.alpha = 0.8
    setButtonMusicType(DataManager.sharedInstance.musicInExecution)
  }
  
  func lockMusicView() {
    viewWithoutMusic.hidden = false
    viewLoading.alpha = 0
    viewWithoutMusic.alpha = 0.8
    viewMusic.alpha = 0.6
    imageMusic.image = UIImage()
    imageMusic.backgroundColor = UIColor.clearColor()
    imageMusic.alpha = 0.6
    labelArtist.text = "Artista"
    labelMusicName.text = "Musica"
    buttonNLike.alpha = 0.6
    butonLike.alpha = 0.6
    labelWithoutMusic.text = "Não há informação da música"
    labelWithoutMusic.textColor = DataManager.sharedInstance.interfaceColor.color
    let imageCD = UIImage(named: "musicIcon.png")
    var imageCDView = UIImageView(frame: imageMusic.frame)
    imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
    imageMusic.image = imageCDView.image
    imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
  }
  @IBAction func buttonNLikeTap(sender: AnyObject) {
    butonLike.alpha = 0.3
    buttonNLike.alpha = 1
    let likeRequest = RequestManager()
    likeRequest.unlikeMusic(StreamingRadioManager.sharedInstance.actualRadio, title: DataManager.sharedInstance.musicInExecution.name, singer: DataManager.sharedInstance.musicInExecution.composer) { (resultUnlike) in
      DataManager.sharedInstance.musicInExecution.setNegative()
      if !resultUnlike {
        Util.displayAlert(title: "Atenção", message: "Problemas ao dar unlike na musica", action: "Ok")
      }
    }
    StreamingRadioManager.sharedInstance.sendNotification()
  }
  @IBAction func buttonLikeTap(sender: AnyObject) {
    butonLike.alpha = 1
    buttonNLike.alpha = 0.3
    let likeRequest = RequestManager()
    likeRequest.likeMusic(StreamingRadioManager.sharedInstance.actualRadio, title: DataManager.sharedInstance.musicInExecution.name, singer: DataManager.sharedInstance.musicInExecution.composer) { (resultLike) in
      DataManager.sharedInstance.musicInExecution.setPositive()
      if !resultLike {
        Util.displayAlert(title: "Atenção", message: "Problemas ao dar like na musica", action: "Ok")
      }
    }
    StreamingRadioManager.sharedInstance.sendNotification()
  }

  @IBAction func openRadioDetail(sender: AnyObject) {
    DataManager.sharedInstance.instantiateRadioDetailView(DataManager.sharedInstance.navigationController, radio: StreamingRadioManager.sharedInstance.actualRadio)
    //DataManager.sharedInstance.miniPlayerView.dismissPlayer()
  }

}
