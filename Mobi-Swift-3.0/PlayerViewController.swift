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
  @IBOutlet weak var buttonLike: UIButton!
  
  @IBOutlet weak var segmentedControlProgram: UISegmentedControl!
  @IBOutlet weak var imageIndicatorDown: UIButton!
  
  @IBOutlet weak var viewWithoutProgram: UIView!
  @IBOutlet weak var labelWithoutMusic: UILabel!
  @IBOutlet weak var labelWithoutProgram: UILabel!
  @IBOutlet weak var viewWithoutMusic: UIView!
  @IBOutlet weak var viewLoading: UIView!
  @IBOutlet weak var viewLoadingProgram: UIView!
  @IBOutlet weak var viewProgram: UIView!
  @IBOutlet weak var viewMusic: UIView!
  @IBOutlet weak var buttonDetailRadio: UIButton!
  @IBOutlet weak var labelIndicatorGuests: UILabel!
  
  @IBOutlet weak var buttonAdvertisement: UIButton!
  
  enum TypeSegmented {
    case music
    case program
  }
  
  var actualSegmented:TypeSegmented = .music
  let notificationCenter = NotificationCenter.default
  var tapCloseButtonActionHandler : ((Void) -> Void)?
  var colorBlack : UIColor!
  var colorWhite : UIColor!
 // var gracenote:GracenoteManager!
  var actualProgram = Program()
  var actualMusic = Music()
  var timeWasRequestedProgram:Date!
  var actualProgramRadio = RadioRealm()
  
  
  @IBOutlet weak var contraintsPropFirstView: NSLayoutConstraint!
  @IBOutlet weak var viewFirst: UIView!
  @IBOutlet weak var viewSeparator: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let screenSize:CGRect = UIScreen.main.bounds
    let screenHeigh = screenSize.height
    if screenHeigh > 510 {
      let newHeight = self.view.frame.size.height * 0.65
      contraintsPropFirstView.constant = newHeight
    } else {
      let newHeight = self.view.frame.size.height * 0.45
      contraintsPropFirstView.constant = newHeight
      self.labelArtist.font = self.labelArtist.font.withSize(13)
      self.labelMusicName.font = self.labelMusicName.font.withSize(16)
      self.labelProgramName.font = self.labelProgramName.font.withSize(16)
    }
    
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "love1.png"), for: UIControlState())
    } else {
      buttonFav.setImage(UIImage(named: "love2.png"), for: UIControlState())
    }
    
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: NSNotification.Name(rawValue: "updateIcons"), object: nil)
    
    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.1, green: (components?[1])!+0.1, blue: (components?[2])!+0.1, alpha: 1).color
    view.backgroundColor = colorWhite
    
    buttonDetailRadio.backgroundColor = UIColor.clear
    viewSeparator.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    segmentedControlProgram.tintColor = DataManager.sharedInstance.interfaceColor.color
    updateInfoOfView()
    segmentedChanged(self)
    
    self.buttonAdvertisement.setBackgroundImage(UIImage(named: "logoAnuncio.png"), for: UIControlState())
    
    let components2 = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    let colorWhite2 =  ColorRealm(name: 45, red: (components2?[0])!+0.1, green: (components2?[1])!+0.1, blue: (components2?[2])!+0.1, alpha: 0.2).color
    self.buttonAdvertisement.backgroundColor = colorWhite2
    
    AdsManager.sharedInstance.setAdvertisement(.playerScreen, completion: { (resultAd) in
      DispatchQueue.main.async {
        if let imageAd = resultAd.image {
          let imageView = UIImageView(frame: self.buttonAdvertisement.frame)
          imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
          self.buttonAdvertisement.setBackgroundImage(imageView.image, for: UIControlState())
        }
      }
    })
    
    
    
    
    imageIndicatorDown.backgroundColor = UIColor.clear
    
    viewSeparator.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    segmentedControlProgram.tintColor = DataManager.sharedInstance.interfaceColor.color
    viewLoadingProgram.isHidden = false
    viewWithoutProgram.isHidden = true
    
    
    
  }
  
  override func viewDidLayoutSubviews() {
    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.1, green: (components?[1])!+0.1, blue: (components?[2])!+0.1, alpha: 1).color
    viewFirst.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: viewFirst.frame, andColors: [colorWhite,colorBlack])
    view.backgroundColor = colorWhite
    
    let components2 = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    let colorWhite2 =  ColorRealm(name: 45, red: (components2?[0])!+0.1, green: (components2?[1])!+0.1, blue: (components2?[2])!+0.1, alpha: 1).color
    self.buttonAdvertisement.backgroundColor = colorWhite2
  }
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    view.backgroundColor = colorWhite
    actualProgram = Program()
    imageIndicatorDown.backgroundColor = UIColor.clear
    
    viewSeparator.backgroundColor = DataManager.sharedInstance.interfaceColor.color
    segmentedControlProgram.tintColor = DataManager.sharedInstance.interfaceColor.color
    updateInfoOfView()
    if !StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "love1.png"), for: UIControlState())
    } else {
      buttonFav.setImage(UIImage(named: "love2.png"), for: UIControlState())
    }
    setButtonMusicType(actualMusic)
    
    if actualSegmented == .program {
      viewMusic.isHidden = true
      viewProgram.isHidden = false
      viewLoadingProgram.isHidden = false
      viewWithoutProgram.isHidden = true
      actualSegmented = .program
      updateProgramOfRadio()
    } else {
      updateInterfaceWithGracenote()
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
    imageLogo.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(StreamingRadioManager.sharedInstance.actualRadio.thumbnail)))
    
    imageLogo.layer.cornerRadius = imageLogo.bounds.height / 6
    imageLogo.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.cgColor
    imageLogo.layer.backgroundColor = UIColor.white.cgColor
    imageLogo.layer.borderColor = colorBlack.cgColor
    imageLogo.layer.borderWidth = 0
    imageLogo.clipsToBounds = true
    labelName.text = StreamingRadioManager.sharedInstance.actualRadio.name.uppercased()
    labelName.textColor = UIColor.white
    if let _ = StreamingRadioManager.sharedInstance.actualRadio.address {
      labelLocal.text = StreamingRadioManager.sharedInstance.actualRadio.address.formattedLocal.uppercased()
      labelLocal.textColor = UIColor.white
    }
    
    if StreamingRadioManager.sharedInstance.currentlyPlaying()  {
      //so mostra o play para a radio que esta tocando
      buttonPlay.setImage(UIImage(named: "pause.png"), for: UIControlState())
    } else {
      buttonPlay.setImage(UIImage(named: "play1.png"), for: UIControlState())
    }
    
    
    labelProgramName.text = "Programa da Manha"
    imagePerson.image = UIImage(named: "logo-pretaAbert.png")
    let imageCD = UIImage(named: "logo-brancaAbert.png")
    var imageCDView = UIImageView(frame: imageMusic.frame)
    imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
    imagePerson.image = imageCDView.image
    imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
    viewWithoutMusic.alpha = 0
    viewLoading.alpha = 0.8
    imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
    imagePerson.layer.borderColor = UIColor.black.cgColor
    imagePerson.layer.borderWidth = 0
    imagePerson.clipsToBounds = true
    labelNamePerson.text = "Marcos"
    labelGuests.text = "Toninho e Fulanhinho de tal"
    
    
    buttonPlay.backgroundColor = UIColor.clear
    
    
    buttonFav.backgroundColor = UIColor.clear
    
  }
  
  @IBAction func segmentedChanged(_ sender: AnyObject) {
    switch segmentedControlProgram.selectedSegmentIndex {
    case 0:
      viewMusic.isHidden = false
      viewProgram.isHidden = true
      actualSegmented = .music
      updateInterfaceWithGracenote()
    case 1:
      viewMusic.isHidden = true
      viewProgram.isHidden = false
      viewLoadingProgram.isHidden = false
      viewWithoutProgram.isHidden = true
      actualSegmented = .program
      updateProgramOfRadio()
    default:
      break
    }
  }
  
  func updateProgramOfRadio() {
    let programRequest = RequestManager()
    if let date = self.timeWasRequestedProgram {
      if date.timeIntervalSinceNow > 20 {
        let idRadio = StreamingRadioManager.sharedInstance.actualRadio.id
        programRequest.requestActualProgramOfRadio(idRadio) { (resultProgram) in
          self.actualProgram = resultProgram
          
          self.timeWasRequestedProgram = Date()
          if self.actualSegmented == .program {
            DispatchQueue.main.async(execute: {
              self.actualProgramRadio = StreamingRadioManager.sharedInstance.actualRadio
              self.updateProgramView()
            })
          }
        }
      } else {
        updateProgramView()
      }
    } else {
      let idRadio = StreamingRadioManager.sharedInstance.actualRadio.id
      programRequest.requestActualProgramOfRadio(idRadio) { (resultProgram) in
        self.actualProgram = resultProgram
        self.timeWasRequestedProgram = Date()
        if self.actualSegmented == .program {
          DispatchQueue.main.async(execute: {
            self.actualProgramRadio = StreamingRadioManager.sharedInstance.actualRadio
            self.updateProgramView()
          })
        }
      }
    }
  }
  
  func updateProgramView() {
    if actualProgram.id == -1 {
      viewLoadingProgram.isHidden = true
      viewWithoutProgram.isHidden = false
      viewWithoutProgram.alpha = 0.8
      labelWithoutProgram.text = ""
      labelGuests.text = "Convidados"
      labelProgramName.text = "Sem informação de programação"
      imagePerson.image = UIImage(named: "logo-pretaAbert.png")
      labelNamePerson.text = "Apresentador"
      labelWithoutProgram.textColor = DataManager.sharedInstance.interfaceColor.color
      imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
      imagePerson.layer.borderColor = UIColor.black.cgColor
      imagePerson.layer.borderWidth = 0
    } else {
      viewLoadingProgram.isHidden = true
      viewWithoutProgram.isHidden = true
      if type(of: actualProgram) == SpecialProgram.self {
        let programSpecial2 = actualProgram as! SpecialProgram
        labelProgramName.text = actualProgram.name
        let identifierImage = actualProgram.announcer.userImage
        imagePerson.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
        imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
        imagePerson.layer.borderColor = UIColor.black.cgColor
        imagePerson.layer.borderWidth = 0
        imagePerson.clipsToBounds = true
        labelNamePerson.text = actualProgram.announcer.name
        labelGuests.text = programSpecial2.guests
      } else {
        labelProgramName.text = actualProgram.name
        let identifierImage = actualProgram.announcer.userImage
        imagePerson.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
        imagePerson.layer.cornerRadius = imagePerson.bounds.height / 2
        imagePerson.layer.borderColor = UIColor.black.cgColor
        imagePerson.layer.borderWidth = 0
        imagePerson.clipsToBounds = true
        labelNamePerson.text = actualProgram.announcer.name
        if let label = labelGuests {
          label.removeFromSuperview()
        }
        if let label = labelIndicatorGuests {
          label.removeFromSuperview()
        }
      }
    }
    
  }
  
  @IBAction func buttonPlayTapped(_ sender: AnyObject) {
    toggle()
    StreamingRadioManager.sharedInstance.sendNotification()
  }
  
  @IBAction func buttonFavTapped(_ sender: AnyObject) {
    let manager = RequestManager()
    if StreamingRadioManager.sharedInstance.actualRadio.isFavorite {
      buttonFav.setImage(UIImage(named: "love1.png"), for: UIControlState())
      
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(false)
      manager.deleteFavRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (result) in
      })
    } else {
      buttonFav.setImage(UIImage(named: "love2.png"), for: UIControlState())
      StreamingRadioManager.sharedInstance.actualRadio.updateIsFavorite(true)
      manager.favRadio(StreamingRadioManager.sharedInstance.actualRadio, completion: { (resultFav) in
      })
    }
    StreamingRadioManager.sharedInstance.sendNotification()
    
    
  }
  
  func updateIcons() {
    if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
      if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(StreamingRadioManager.sharedInstance.actualRadio)) {
        buttonPlay.setImage(UIImage(named: "pause.png"), for: UIControlState())
      } else {
        buttonPlay.setImage(UIImage(named: "play1.png"), for: UIControlState())
      }
    } else {
      buttonPlay.setImage(UIImage(named: "play1.png"), for: UIControlState())
    }
  }
  
  @IBAction func hidePlayerAction(_ sender: AnyObject) {
    self.tapCloseButtonActionHandler?()
    self.dismiss(animated: true, completion: nil)
    DataManager.sharedInstance.miniPlayerView.hidePlayer()
  }
  
  func findMusicLastAndCompare() -> Bool {
    if let _ = DataManager.sharedInstance.lastMusicRadio {
      if DataManager.sharedInstance.lastMusicRadio.radio == StreamingRadioManager.sharedInstance.actualRadio {
        if !DataManager.sharedInstance.lastMusicRadio.music.isMusicOld() {
          self.updateMusicViewWithMusic(DataManager.sharedInstance.lastMusicRadio.music)
          actualMusic = DataManager.sharedInstance.lastMusicRadio.music
          return true
        } else {
          return false
        }
      } else {
        return false
      }
    } else {
      return false
    }
  }
  
  func updateInterfaceWithGracenote() {
    loadingMusicView()
    
    
    if !findMusicLastAndCompare() {
      if let _ = actualMusic.respectiveRadio {
        if actualMusic.respectiveRadio == StreamingRadioManager.sharedInstance.actualRadio {
          if let _ = actualMusic.timeWasDiscovered {
            if actualMusic.isMusicOld() {
              if let _ = actualMusic.name {
                if actualMusic.isMusicOld() {
                  self.requestGracenote({ (result) in
                    if result.name != "" {
                      self.updateMusicViewWithMusic(self.actualMusic)
                      self.actualMusic.updateDate()
                    } else {
                      self.lockMusicView()
                    }
                  })
                } else {
                    updateMusicViewWithMusic(actualMusic)
                    self.actualMusic.updateDate()
                  
                }
              } else {
                self.requestGracenote({ (result) in
                  if result.name != "" {
                    self.updateMusicViewWithMusic(self.actualMusic)
                    self.actualMusic.updateDate()
                    
                  } else {
                    self.lockMusicView()
                  }
                })
                }
            } else {
              self.updateMusicViewWithMusic(actualMusic)
            }
          } else {
            requestGracenote({ (result) in
              if result.name != "" {
                self.updateMusicViewWithMusic(self.actualMusic)
                self.actualMusic.updateDate()
              } else {
                self.lockMusicView()
              }
            })
          }
        } else {
          requestGracenote({ (result) in
            if result.name != "" {
              self.updateMusicViewWithMusic(self.actualMusic)
              self.actualMusic.updateDate()
            } else {
              self.lockMusicView()
            }
          })
        }
      } else {
        requestGracenote({ (result) in
          if result.name != "" {
            self.updateMusicViewWithMusic(self.actualMusic)
            self.actualMusic.updateDate()
          } else {
            self.lockMusicView()
          }
        })
      }
      
      
    }
    
  }
  
  func requestGracenote(_ completion: @escaping (_ result: Music) -> Void) {
    if let audioChannel = StreamingRadioManager.sharedInstance.actualRadio.audioChannels.first {
      if audioChannel.existRdsLink {
        let rdsRequest = RequestManager()
        rdsRequest.downloadRdsInfo((StreamingRadioManager.sharedInstance.actualRadio.audioChannels.first?.linkRds.link)!) { (result) in
          if let resultTest = result[true] {
            if resultTest.existData {
                DispatchQueue.main.async(execute: {
                    var musicRadio = MusicRadio()
                    musicRadio.music = Music(id: "4", name: resultTest.title, albumName: "", composer: resultTest.artist, coverArt: "")
                    if musicRadio.music.name != "" {
                            self.actualMusic = musicRadio.music
                            DataManager.sharedInstance.lastMusicRadio = musicRadio
                        
                            self.actualMusic.updateRadio(StreamingRadioManager.sharedInstance.actualRadio)
                            completion(self.actualMusic)
                    } else {
                        self.actualMusic = Music()
                        completion(self.actualMusic)
                    }
                })
            } else {
              completion(Music())
            }
          } else {
            completion(Music())
          }
        }
      } else {
        completion(Music())
      }
    } else {
      completion(Music())
    }
    
  }
  
//  func updateMusicViewWithMusic(_ music:Music) {
//    if actualMusic.id != ""  {
//      viewWithoutMusic.isHidden = true
//      viewWithoutMusic.alpha = 0
//      labelMusicName.text = actualMusic.name
//      labelArtist.text = actualMusic.composer
//      buttonNLike.backgroundColor = UIColor.clear
//      buttonLike.backgroundColor = UIColor.clear
//      if music.coverArt != ""{
//        
//      }
//      setButtonMusicType(actualMusic)
//      viewLoading.alpha = 0
//      viewWithoutMusic.alpha = 0
//      viewMusic.alpha = 1
//      imageMusic.alpha = 1
//      buttonNLike.alpha = 1
//      buttonLike.alpha = 1
//      labelWithoutMusic.text = ""
//    } else {
//      lockMusicView()
//    }
//  }
  
  func updateMusicViewWithMusic(_ music:Music) {
    if actualMusic.id != ""  {
      viewWithoutMusic.isHidden = true
      viewWithoutMusic.alpha = 0
      labelMusicName.text = actualMusic.name
      labelArtist.text = actualMusic.composer
      buttonNLike.backgroundColor = UIColor.clear
      buttonLike.backgroundColor = UIColor.clear
      if let image = actualMusic.imageCover {
        self.imageMusic.image = image
      }
      
      viewLoading.alpha = 0
      viewWithoutMusic.alpha = 0
      viewMusic.alpha = 1
      imageMusic.alpha = 1
      buttonNLike.alpha = 1
      buttonLike.alpha = 1
      setButtonMusicType(actualMusic)
      labelWithoutMusic.text = ""
    } else {
      lockMusicView()
    }
  }
  
  func setButtonMusicType(_ music:Music) {
    if music.isPositive {
      buttonLike.alpha = 1
      buttonNLike.alpha = 0.3
    }
    if music.isNegative {
      buttonLike.alpha = 0.3
      buttonNLike.alpha = 1
    }
  }
  
  func loadingMusicView() {
    buttonNLike.backgroundColor = UIColor.clear
    buttonLike.backgroundColor = UIColor.clear
    viewMusic.alpha = 0.8
    imageMusic.image = UIImage()
    imageMusic.backgroundColor = UIColor.clear
    imageMusic.alpha = 0.6
    labelArtist.text = "Artista"
    labelMusicName.text = "Musica"
    buttonNLike.alpha = 0.6
    buttonLike.alpha = 0.6
    labelWithoutMusic.text = "Sem informação da música"
    labelWithoutMusic.textColor = DataManager.sharedInstance.interfaceColor.color
    let imageCD = UIImage(named: "logo-brancaAbert.png")
    var imageCDView = UIImageView(frame: imageMusic.frame)
    imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
    imageMusic.image = imageCDView.image
    imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
    viewWithoutMusic.alpha = 0
    viewLoading.alpha = 0.8
    setButtonMusicType(actualMusic)
  }
  
  func lockMusicView() {
    viewWithoutMusic.isHidden = false
    viewLoading.alpha = 0
    viewWithoutMusic.alpha = 0.8
    viewMusic.alpha = 0.6
    imageMusic.image = UIImage()
    imageMusic.backgroundColor = UIColor.clear
    imageMusic.alpha = 0.6
    labelArtist.text = "Artista"
    labelMusicName.text = "Sem informação"
    buttonNLike.alpha = 0.6
    buttonLike.alpha = 0.6
    labelWithoutMusic.text = ""
    labelWithoutMusic.textColor = DataManager.sharedInstance.interfaceColor.color
    let imageCD = UIImage(named: "musicIcon.png")
    var imageCDView = UIImageView(frame: imageMusic.frame)
    imageCDView = Util.tintImageWithColor(DataManager.sharedInstance.interfaceColor.color, image: imageCD!)
    imageMusic.image = imageCDView.image
    imageMusic.tintColor = DataManager.sharedInstance.interfaceColor.color
  }
  @IBAction func buttonNLikeTap(_ sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      buttonLike.alpha = 0.3
      buttonNLike.alpha = 1
      self.actualMusic.setNegative()
      DataManager.sharedInstance.musicInExecution = actualMusic
      let likeRequest = RequestManager()
      likeRequest.unlikeMusic(StreamingRadioManager.sharedInstance.actualRadio, title: actualMusic.name, singer: actualMusic.composer) { (resultUnlike) in
        
        if !resultUnlike {
          Util.displayAlert(title: "Atenção", message: "Problemas ao dar unlike na musica", action: "Ok")
        }
      }
      StreamingRadioManager.sharedInstance.sendNotification()
    } else {
      Util.displayAlert(self, title: "Atenção", message: "Para utilizar este recurso é preciso estar logado, logue no Menu", action: "Ok")
    }
  }
  @IBAction func buttonLikeTap(_ sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      buttonLike.alpha = 1
      buttonNLike.alpha = 0.3
      self.actualMusic.setPositive()
      DataManager.sharedInstance.musicInExecution = actualMusic
      let likeRequest = RequestManager()
      likeRequest.likeMusic(StreamingRadioManager.sharedInstance.actualRadio, title: actualMusic.name, singer: actualMusic.composer) { (resultLike) in
        
        if !resultLike {
          Util.displayAlert(title: "Atenção", message: "Problemas ao dar like na musica", action: "Ok")
        }
      }
      StreamingRadioManager.sharedInstance.sendNotification()
    } else {
      Util.displayAlert(self, title: "Atenção", message: "Para utilizar este recurso é preciso estar logado, logue no Menu", action: "Ok")
    }
  }
  
  @IBAction func openRadioDetail(_ sender: AnyObject) {
    DataManager.sharedInstance.instantiateRadioDetailView(DataManager.sharedInstance.navigationController, radio: StreamingRadioManager.sharedInstance.actualRadio)
    //DataManager.sharedInstance.miniPlayerView.dismissPlayer()
  }
  
}
