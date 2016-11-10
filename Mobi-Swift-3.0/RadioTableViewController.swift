//
//  RadioTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/27/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import AVFoundation
import Kingfisher
import ImageViewer

class RadioTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OUTLETS ---
  ///////////////////////////////////////////////////////////
  
  @IBOutlet weak var buttonActionNav: UIBarButtonItem!
  @IBOutlet weak var segmentedMenu: UISegmentedControl!
  @IBOutlet weak var viewTop: UIView!
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VARIABLE SET ---
  ///////////////////////////////////////////////////////////
  
  var firstTimeShowed = true
  var cellMusicIsShowed = false
  var selectedRadio = RadioRealm()
  var selectedComment:Comment!
  var actualRadio = RadioRealm()
  var stars = [UIImageView]()
  var actualComments = [Comment]()
  var actualMusic = Music()
  var actualProgram = Program()
  var similarRadios = [RadioRealm]()
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var selectedMode:SelectedRadioMode = .DetailRadio
  var colorBlack : UIColor!
  var colorWhite : UIColor!
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  var needToUpdateCell = false
  var needToUpdateIcons = false
  
  static var selectedImageButton:UIImage!
  
  enum SelectedRadioMode {
    case DetailRadio
    case Wall
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- VARIABLE SET ---
    ///////////////////////////////////////////////////////////
    
    let button = UIButton(type: UIButtonType.InfoLight)
    buttonActionNav = UIBarButtonItem.init(customView: button)
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    selectedMode == .DetailRadio
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 1).color
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    self.clearsSelectionOnViewWillAppear = true
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    let audioManager = RequestManager()
    audioManager.getAudioChannelsFromRadio(actualRadio) { (result) in
      self.updateInterfaceWithGracenote()
    }
    
    
    let similarRequest = RequestManager()
    
    similarRequest.requestSimilarRadios(0, pageSize: 20, radioToCompare: actualRadio) { (resultSimilar) in
      self.similarRadios = resultSimilar
      if self.selectedMode == .DetailRadio {
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
      }
    }
    
    let scoreRequest = RequestManager()
    scoreRequest.getRadioScore(actualRadio) { (resultScore) in
      if self.selectedMode == .DetailRadio {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RadioDetailTableViewCell
        if self.actualRadio.score == -1 {
          cell.labelScore.text = "-"
        } else {
          cell.labelScore.text = "\(self.actualRadio.score)"
        }
      }
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func viewWillAppear(animated: Bool) {
    defineBarButton()
    
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    switch selectedMode {
    case .DetailRadio:
      return 5
    case .Wall:
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .DetailRadio:
      if section == 2 {
        return 2
      }
      else if section == 3 {
        if similarRadios.count <= 3 {
          return similarRadios.count
        } else {
          return 4
        }
      } else if section == 4 {
        return 3
      } else {
        return 1
      }
    case .Wall:
      if firstTimeShowed {
        return 1
      } else {
        return actualComments.count + 1
      }
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch selectedMode {
    case .DetailRadio:
      switch indexPath.section {
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("detailRadio", forIndexPath: indexPath) as! RadioDetailTableViewCell
        cell.imageRadio.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
        cell.imageRadio.layer.cornerRadius = cell.imageRadio.bounds.height / 6
        cell.imageRadio.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.CGColor
        cell.imageRadio.layer.backgroundColor = UIColor.whiteColor().CGColor
        cell.imageRadio.layer.borderWidth = 0
        cell.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: cell.frame, andColors: [colorBlack,colorWhite])
        cell.labelName.text = actualRadio.name.uppercaseString
        cell.labelName.textColor = UIColor.whiteColor()
        if let _ = actualRadio.address {
          cell.labelLocal.text = actualRadio.address.formattedLocal.uppercaseString
          cell.labelLocal.textColor = UIColor.whiteColor()
        }
        cell.labelLikes.text = "\(actualRadio.likenumber)"
        cell.labelLikes.textColor = UIColor.whiteColor()
        if actualRadio.score == -1 {
          cell.labelScore.text = "-"
        } else {
          cell.labelScore.text = "\(actualRadio.score)"
        }
        cell.labelScore.textColor = UIColor.whiteColor()
        cell.labelLikesDescr.textColor = UIColor.whiteColor()
        cell.labelScoreDescr.textColor = UIColor.whiteColor()
        cell.viewBack.alpha = 0
        cell.playButton.backgroundColor = UIColor.clearColor()
        cell.playButton.layer.cornerRadius = cell.playButton.bounds.height / 2
        cell.imageRadio.layer.borderWidth = 0
        cell.imageRadio.clipsToBounds = true
        cell.selectionStyle = .None
        if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
          cell.playButton.setImage(UIImage(named: "pause.png"), forState: .Normal)
        } else {
          cell.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
        }
        return cell
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("actualMusic", forIndexPath: indexPath) as! MusicTableViewCell
        if let _ = actualMusic.name {
          cell.labelMusicName.text = actualMusic.name
          cell.labelArtist.text = actualMusic.composer
        }
        else {
          cell.labelMusicName.text = "Musica"
          cell.labelArtist.text = "Artista"
        }
        cell.buttonNLike.backgroundColor = UIColor.clearColor()
        cell.buttonLike.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        if !cellMusicIsShowed {
          cell.loadInfo()
          cellMusicIsShowed = true
        }
        return cell
      case 2:
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("actualProgram", forIndexPath: indexPath) as! ActualProgramTableViewCell
          cell.tag = 150
          if actualProgram.id == -1 {
            cell.lockView()
            return cell
          } else {
            if actualProgram.dynamicType == SpecialProgram.self {
              let programSpecial2 = actualProgram as! SpecialProgram
              cell.labelName.text = actualProgram.name
              cell.labelSecondName.text = ""
              let identifierImage = actualProgram.announcer.userImage
              cell.imagePerson.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
              cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
              cell.imagePerson.layer.borderColor = UIColor.blackColor().CGColor
              cell.imagePerson.layer.borderWidth = 0
              cell.imagePerson.clipsToBounds = true
              cell.labelNamePerson.text = actualProgram.announcer.name
              cell.labelGuests.text = programSpecial2.guests
              return cell
            } else {
              cell.labelName.text = actualProgram.name
              cell.labelSecondName.text = ""
              let identifierImage = actualProgram.announcer.userImage
              cell.imagePerson.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
              cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
              cell.imagePerson.layer.borderColor = UIColor.blackColor().CGColor
              cell.imagePerson.layer.borderWidth = 0
              cell.imagePerson.clipsToBounds = true
              cell.labelNamePerson.text = actualProgram.announcer.name
            }
          }
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("adsCell", forIndexPath: indexPath) as! AdsTableViewCell
          let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
          let colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 0.2).color
          cell.adsButton.backgroundColor = colorWhite
          cell.adsButton.setBackgroundImage(UIImage(named: "anuncio3.png"), forState: .Normal)
          cell.selectionStyle = .None
          
          print("Tamanho do adbutton \(cell.adsButton.frame.size)")
          AdsManager.sharedInstance.setAdvertisement(.PlayerScreen, completion: { (resultAd) in
            dispatch_async(dispatch_get_main_queue()) {
              if let imageAd = resultAd.image {
                let imageView = UIImageView(frame: cell.adsButton.frame)
                imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
                cell.adsButton.setBackgroundImage(imageView.image, forState: .Normal)
              }
            }
          })
          return cell
        }
      case 3:
        if indexPath.row <= similarRadios.count-1 {
          let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
          cell.labelName.text = similarRadios[indexPath.row].name
          if let address = similarRadios[indexPath.row].address {
            cell.labelLocal.text = address.formattedLocal
          }
          cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(similarRadios[indexPath.row].thumbnail)))
          cell.labelDescriptionOne.text = "\(similarRadios[indexPath.row].likenumber)"
          cell.widthTextOne.constant = 30
          cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
          cell.labelDescriptionTwo.text = ""
          if similarRadios[indexPath.row].isFavorite {
            cell.imageSmallOne.image = UIImage(named: "heartRed.png")
          } else {
            cell.imageSmallOne.image = UIImage(named: "heart.png")
          }
          cell.tag = 120
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("readMoreCell", forIndexPath: indexPath) as! ReadMoreTableViewCell
          cell.labelReadMore.text = "Ver Mais"
          cell.tag = 140
          return cell
        }
      case 4:
        switch indexPath.row {
        case 0:
          let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = "Avaliações"
          cell.tag = 110
          return cell
        case 1:
          let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = "Contato"
          cell.tag = 130
          return cell
        default:
          let cell = UITableViewCell()
          return cell
        }
      default:
        let cell = UITableViewCell()
        return cell
      }
    case .Wall :
      if !firstTimeShowed {
        if indexPath.row <= actualComments.count-1 {
          if actualComments[indexPath.row].postType == .Audio {
            let cell = tableView.dequeueReusableCellWithIdentifier("wallAudioCell", forIndexPath: indexPath) as! WallAudioPlayerTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            cell.textViewWall.text = actualComments[indexPath.row].text
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)))
            }
            cell.identifier = actualComments[indexPath.row].audio
            return cell
            
          }
          if actualComments[indexPath.row].postType == .Image {
            let cell = tableView.dequeueReusableCellWithIdentifier("wallImageCell", forIndexPath: indexPath) as! WallImageTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            cell.textViewWall.text = actualComments[indexPath.row].text
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)))
            }
            cell.buttonZoomImage.tag = indexPath.row
            cell.tag = indexPath.row
            cell.imageAttachment.kf_showIndicatorWhenLoading = true
            if !cell.isReloadCell {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                cell.imageAttachment?.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualComments[indexPath.row].image)), placeholderImage: UIImage(), optionsInfo: [.Transition(.Fade(0.2))], progressBlock: { (receivedSize, totalSize) in
                  
                  }, completionHandler: { (image, error, cacheType, imageURL) in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                      if self.selectedMode == .Wall {
                        if let image2 = image {
                          if cell.tag == indexPath.row && !cell.isReloadCell{
                            let ratio = (image2.size.height)/(image2.size.width)
                            cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: ratio*cell.frame.width)
                            //cell.imageAttachment.image = image
                            tableView.beginUpdates()
                            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            tableView.endUpdates()
                            cell.tag = 1000
                            cell.isReloadCell = true
                          }
                        }
                      }
                    })
                })
              })
            }
            cell.buttonZoomImage.backgroundColor = UIColor.clearColor()
            return cell
          } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("wallCell", forIndexPath: indexPath) as! WallTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            cell.textViewWall.text = actualComments[indexPath.row].text
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)))
            }
            return cell
          }
        } else {
          let cell = UITableViewCell()
          cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
          return cell
        }
      } else {
        let cell = UITableViewCell()
        return cell
      }
    }
    let cell = UITableViewCell()
    return cell
  }
  
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch selectedMode {
    case .DetailRadio:
      switch section {
      case 0:
        return ""
      case 1:
        return "AO VIVO"
      case 2:
        return "PROGRAMA ATUAL"
      case 3:
        return "RADIOS SEMELHANTES"
      case 4:
        return "OUTROS"
      default:
        return ""
      }
    default:
      return ""
    }
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    let cellTag = (cell?.tag)!
    switch cellTag {
    case 110:
      performSegueWithIdentifier("reviewSegue", sender: self)
    case 120:
      DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: DataManager.sharedInstance.favoriteRadios[indexPath.row])
    case 130:
      performSegueWithIdentifier("contactSegue", sender: self)
    case 150:
      performSegueWithIdentifier("programSegue", sender: self)
    default:
      break
    }
    if selectedMode == .Wall {
      selectedComment = actualComments[indexPath.row]
      performSegueWithIdentifier("showSubCommentsSegue", sender: self)
    }
  }
  
  @IBAction func buttonNLike(sender: AnyObject) {
    let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
    cell?.buttonLike.alpha = 0.3
    cell?.buttonNLike.alpha = 1
    let likeRequest = RequestManager()
    likeRequest.unlikeMusic(actualRadio, title: actualMusic.name, singer: actualMusic.composer) { (resultUnlike) in
      self.actualMusic.setNegative()
      if !resultUnlike {
        Util.displayAlert(title: "Atenção", message: "Problemas ao dar unlike na musica", action: "Ok")
      }
    }
  }
  @IBAction func buttonLike(sender: AnyObject) {
    let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
    cell?.buttonLike.alpha = 1
    cell?.buttonNLike.alpha = 0.3
    let likeRequest = RequestManager()
    likeRequest.likeMusic(actualRadio, title: actualMusic.name, singer: actualMusic.composer) { (resultLike) in
      self.actualMusic.setPositive()
      if !resultLike {
        Util.displayAlert(title: "Atenção", message: "Problemas ao dar like na musica", action: "Ok")
      }
    }
  }
  
  func setButtonMusicType(music:Music) {
    if selectedMode == .DetailRadio {
      let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
      if music.isPositive {
        cell?.buttonLike.alpha = 1
        cell?.buttonNLike.alpha = 0.3
      }
      if music.isNegative {
        cell?.buttonLike.alpha = 0.3
        cell?.buttonNLike.alpha = 1
      }
    }
  }
  
  @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
    switch segmentedMenu.selectedSegmentIndex {
    case 0:
      selectedMode = .DetailRadio
    case 1:
      selectedMode = .Wall
      view.addSubview(activityIndicator)
      activityIndicator.hidden = false
      tableView.allowsSelection = false
      let requestManager = RequestManager()
      requestManager.requestWallOfRadio(actualRadio, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
        self.actualComments = resultWall
        self.firstTimeShowed = false
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.self.activityIndicator.removeFromSuperview()
        self.tableView.reloadData()
      })
    default:
      selectedMode = .DetailRadio
    }
    defineBarButton()
    tableView.reloadData()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHER FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func reloadCell(indexPathTest:NSIndexPath) {
    if selectedMode == .Wall {
      
      tableView.reloadRowsAtIndexPaths([indexPathTest], withRowAnimation: .None)
      
    }
  }
  
  func updateInterfaceWithGracenote() {
    if let audioChannel = actualRadio.audioChannels.first {
      if audioChannel.existRdsLink {
        let rdsRequest = RequestManager()
        rdsRequest.downloadRdsInfo((actualRadio.audioChannels.first?.linkRds.link)!) { (result) in
          if let resultTest = result[true] {
            if resultTest.existData {
              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let gracenote = GracenoteManager(bool: true)
                gracenote.findMatch("", trackTitle: resultTest.title, albumArtistName: resultTest.artist, trackArtistName: "", composerName: "", completion: { (resultGracenote) in
                  dispatch_async(dispatch_get_main_queue(), {
                    if resultGracenote.name != "" {
                      if self.selectedMode == .DetailRadio {
                        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
                        cell?.unlockContent()
                        cell?.labelMusicName.text = resultGracenote.name
                        cell?.labelArtist.text = resultGracenote.composer
                        self.setButtonMusicType(resultGracenote)
                        if resultGracenote.coverArt != ""{
                          gracenote.downloadImageArt(resultGracenote.coverArt, completion: { (resultImg) in
                            dispatch_async(dispatch_get_main_queue()) {
                              if self.selectedMode == .DetailRadio {
                                cell?.imageMusic.image = resultImg
                              }
                            }
                            
                          })
                        }
                        self.actualMusic = resultGracenote
                      }
                    } else {
                      let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
                      cell?.lockContent()
                    }
                  })
                })
                
              })
              
            } else {
              let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
              cell?.lockContent()
            }
          } else {
            let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
            cell?.lockContent()
          }
        }
      } else {
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
        cell?.lockContent()
      }
    } else {
      let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1)) as? MusicTableViewCell
      cell?.lockContent()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "programSegue" {
      let programTV = (segue.destinationViewController as! ProgramsTableViewController)
      programTV.actualRadio = actualRadio
    }
    if segue.identifier == "reviewSegue" {
      let reviewVC = segue.destinationViewController as! ReviewTableViewController
      reviewVC.actualRadio = actualRadio
    }
    if segue.identifier == "createPublicationSegue" {
      let createVC = segue.destinationViewController as! SendPublicationViewController
      createVC.actualRadio = actualRadio
      createVC.actualMode = .Wall
    }
    if segue.identifier == "showSubCommentsSegue" {
      let createVC = segue.destinationViewController as! CommentsTableViewController
      createVC.actualRadio = actualRadio
      createVC.actualComment = selectedComment
    }
    if segue.identifier == "contactSegue" {
      let contactVC = segue.destinationViewController as! ContactRadioTableViewController
      contactVC.actualRadio = actualRadio
    }
  }
  
  @IBAction func buttonPlayTapped(sender: AnyObject) {
    if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
      if StreamingRadioManager.sharedInstance.currentlyPlaying() {
        StreamingRadioManager.sharedInstance.stop()
      } else {
        StreamingRadioManager.sharedInstance.play(actualRadio)
        DataManager.sharedInstance.miniPlayerView.miniPlayerView.hidden = false
        DataManager.sharedInstance.miniPlayerView.tapMiniPlayerButton(DataManager.sharedInstance.miniPlayerView)
      }
    } else {
      StreamingRadioManager.sharedInstance.play(actualRadio)
      DataManager.sharedInstance.miniPlayerView.miniPlayerView.hidden = false
      DataManager.sharedInstance.miniPlayerView.tapMiniPlayerButton(DataManager.sharedInstance.miniPlayerView)
    }
    StreamingRadioManager.sharedInstance.sendNotification()
  }
  
  func updateIcons() {
    if let cellFirst = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? RadioDetailTableViewCell {
      
      if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
        if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
          cellFirst.playButton.setImage(UIImage(named: "pause.png"), forState: .Normal)
        } else {
          cellFirst.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
        }
      } else {
        cellFirst.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
      }
    } else {
      needToUpdateCell = true
    }
    defineBarButton()
    setButtonMusicType(DataManager.sharedInstance.musicInExecution)
  }
  
  func buttonFavTap() {
    let manager = RequestManager()
    if actualRadio.isFavorite {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heart.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      actualRadio.updateIsFavorite(false)
      manager.deleteFavRadio(actualRadio, completion: { (result) in
      })
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartRedFilled.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      actualRadio.updateIsFavorite(true)
      manager.favRadio(actualRadio, completion: { (resultFav) in
      })
    }
  }
  
  func createComment() {
    if DataManager.sharedInstance.isLogged {
      performSegueWithIdentifier("createPublicationSegue", sender: self)
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "É preciso estar logado para criar publicações", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  func defineBarButton() {
    if selectedMode == .DetailRadio {
      if !actualRadio.isFavorite {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heart.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartRedFilled.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      }
    } else if selectedMode == .Wall {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "plus.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.createComment))
      
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .Wall {
      str = "Nenhuma publicação realizada no mural"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .Wall {
      str = "Clique aqui e seja o primeiro a criar uma publicação no mural de  \(actualRadio.name)"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    performSegueWithIdentifier("createPublicationSegue", sender: self)
  }
  
  @IBAction func adsButtonTap(sender: AnyObject) {
    
  }
  
  @IBAction func zoomImageButtonTap(sender: AnyObject) {
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! WallImageTableViewCell
    
    RadioTableViewController.selectedImageButton = cell.imageAttachment.image!
    let imageProvider: ImageProvider = PoorManProvider()
    let buttonAssets = CloseButtonAssets(normal: UIImage(named:"arrowWhite")!, highlighted: UIImage(named: "arrowWhite"))
    
    let configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets, backgroundColor: UIColor.blackColor())
    let imageViewer = ImageViewerController(imageProvider: imageProvider, configuration: configuration, displacedView: sender as! UIView)
    self.presentImageViewer(imageViewer)
  }
}

class PoorManProvider:ImageProvider {
  
  var imageCount: Int = 0
  func provideImage(completion: UIImage? -> Void) {
    if let image = RadioTableViewController.selectedImageButton {
      completion(image)
    }
    
  }
  
  func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
    completion(UIImage())
  }
}