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
import Contacts


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
  var contactRadio = ContactRadio()
  var needToUpdateCell = false
  var needToUpdateIcons = false
  
  var avAudioPlayer:AVAudioPlayer!
  
  var updateFistCell = false
  var contactStore = CNContactStore()
  static var selectedImageButton:UIImage!
  
  var existAudioChannel = false
  
  enum SelectedRadioMode {
    case DetailRadio
    case Wall
  }
  
  
  struct ImageWithSize {
    var image:UIImage!
    var size:CGSize!
  }
  
  var sizesImage = Dictionary<NSIndexPath,ImageWithSize>()
  
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
    colorWhite =  ColorRealm(name: 45, red: components[0]+0.15, green: components[1]+0.15, blue: components[2]+0.15, alpha: 1).color
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    self.clearsSelectionOnViewWillAppear = true
    
    self.navigationController? .setNavigationBarHidden(false, animated:true)
    let backButton = UIButton(type: UIButtonType.Custom)
    backButton.addTarget(self, action: #selector(RadioTableViewController.backFunction), forControlEvents: UIControlEvents.TouchUpInside)
    backButton.setTitle("< Voltar", forState: UIControlState.Normal)
    backButton.sizeToFit()
    let backButtonItem = UIBarButtonItem(customView: backButton)
    self.navigationItem.leftBarButtonItem = backButtonItem
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    let audioManager = RequestManager()
    audioManager.getAudioChannelsFromRadio(actualRadio) { (result) in
      self.updateInterfaceWithGracenote()
      self.existAudioChannel = true
    }
    
    
    let similarRequest = RequestManager()
    
    similarRequest.requestSimilarRadios(0, pageSize: 20, radioToCompare: actualRadio) { (resultSimilar) in
      self.similarRadios = resultSimilar
      if self.selectedMode == .DetailRadio {
        self.tableView.reloadSections(NSIndexSet(index: 4), withRowAnimation: .Automatic)
      }
    }
    
    let scoreRequest = RequestManager()
    scoreRequest.getRadioScore(actualRadio) { (resultScore) in
      if self.selectedMode == .DetailRadio {
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? RadioDetailTableViewCell {
          
          if self.actualRadio.score == -1 {
            cell.labelScore.text = "-"
          } else {
            cell.labelScore.text = "\(self.actualRadio.score)"
          }
        }
      }
    }
    
    let requestContact = RequestManager()
    requestContact.requestPhonesOfStation(actualRadio) { (resultPhones) in
      let requestSocial = RequestManager()
      requestSocial.requestSocialNewtworkOfStation(self.actualRadio, completion: { (resultSocial) in
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        var face = ""
        var twitter = ""
        var instagram = ""
        var email = ""
        for social in resultSocial {
          if social.type == "Facebook" {
            face = social.text
          }
          else if social.type == "Instagram" {
            instagram = social.text
          }
          else if social.type == "Twitter" {
            twitter = social.text
          }
          else if social.type == "E-mail" {
            email = social.text
          }
        }
        let contact = ContactRadio(email: email, facebook: face, twitter: twitter, instagram: instagram, phoneNumbers: resultPhones)
        self.contactRadio = contact
        if self.selectedMode == .DetailRadio {
          self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        }
      })
    }
    
    
    let programRequest = RequestManager()
    let idRadio = actualRadio.id
    programRequest.requestActualProgramOfRadio(idRadio) { (resultProgram) in
      self.actualProgram = resultProgram
      
      dispatch_async(dispatch_get_main_queue(), {
        if self.selectedMode == .DetailRadio {
          self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 2)], withRowAnimation: .None)
        }
      })
      
      
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
  
  func backFunction() {
    self.navigationController?.popViewControllerAnimated(true)
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
      if section == 0 {
        if !contactRadio.existSocialNew {
          return 1
        } else {
          return 2
        }
      }
      if section == 2 {
        return 2
      }
      else if section == 4 {
        if similarRadios.count <= 3 {
          return similarRadios.count + 1
        } else {
          return 4 + 1
        }
      } else if section == 3 {
        if actualRadio.iosLink != "" {
          return 3
        } else {
          return 2
        }
      } else {
        return 1
      }
    case .Wall:
      if firstTimeShowed {
        return 1
      } else {
        if actualComments.count == 0 {
          return 0
        } else {
          return actualComments.count + 1
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.imageView?.kf_cancelDownloadTask()
    
  }
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  override func viewDidAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = true
    if let _ = tableView.indexPathForSelectedRow {
      let index = self.tableView.indexPathForSelectedRow
      self.tableView.deselectRowAtIndexPath(index!, animated: true)
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    if selectedMode == .DetailRadio {
      if let cellDetail = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) {
        cellDetail.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: cellDetail.frame, andColors: [colorWhite,colorBlack])
      }
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch selectedMode {
    case .DetailRadio:
      switch indexPath.section {
      case 0:
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("detailRadio", forIndexPath: indexPath) as! RadioDetailTableViewCell
          cell.imageRadio.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
          cell.imageRadio.layer.cornerRadius = cell.imageRadio.bounds.height / 6
          cell.imageRadio.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.CGColor
          cell.imageRadio.layer.backgroundColor = UIColor.whiteColor().CGColor
          cell.imageRadio.layer.borderWidth = 0
          cell.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: cell.frame, andColors: [colorWhite,colorBlack])
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
          cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
          if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
            cell.playButton.setImage(UIImage(named: "pause.png"), forState: .Normal)
          } else {
            cell.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
          }
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("socialNetCell", forIndexPath: indexPath) as! SocialNetworkTableViewCell
          cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
          cell.backgroundColor = DataManager.sharedInstance.interfaceColor.color
          let socialNetworks = ["Facebook","Instagram","Twitter"]
          for socialNetworkTitle in socialNetworks {
            var hasSocial = false
            for social in contactRadio.arraySocial {
              let type = (social["Type"])!
              //              let value = social["Value"]
              if type == socialNetworkTitle {
                hasSocial = true
                break
              }
            }
            if !hasSocial {
              if let _ = cell.buttonFace {
                if socialNetworkTitle == "Facebook" {
                  cell.buttonFace.removeFromSuperview()
                }
              }
              if let _ = cell.buttonInsta {
                if socialNetworkTitle == "Instagram" {
                  cell.buttonInsta.removeFromSuperview()
                }
              }
              if let _ = cell.buttonTwitter {
                if socialNetworkTitle == "Twitter" {
                  cell.buttonTwitter.removeFromSuperview()
                }
              }
            }
            var existWhats = false
            
            for number in contactRadio.phoneNumbers {
              if let _ = number.phoneNumber {
                if number.phoneType.name == "WhatsApp" {
                  existWhats = true
                }
              }
            }
            if !existWhats {
              if let whats = cell.buttonWhats {
                whats.removeFromSuperview()
              }
            }
          }
          cell.updateConstraintsIfNeeded()
          cell.layoutIfNeeded()
          cell.selectionStyle = .None
          return cell
        }
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
              cell.unlockView()
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
              if let label = cell.labelGuests {
                label.removeFromSuperview()
              }
              if let label = cell.labelIndicatorGuests {
                label.removeFromSuperview()
              }
              cell.unlockView()
              return cell
            }
          }
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("adsCell", forIndexPath: indexPath) as! AdsTableViewCell
          let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
          let colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 0.2).color
          cell.adsButton.backgroundColor = colorWhite
          cell.adsButton.setBackgroundImage(UIImage(named: "logoAnuncio.png"), forState: .Normal)
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
      case 4:
        if similarRadios.count >= 4 {
          if indexPath.row == 4 {
            let cell = UITableViewCell()
            return cell
          }
          else if indexPath.row <= similarRadios.count-1 {
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
        } else {
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
            let cell = UITableViewCell()
            cell.selectionStyle = .None
            return cell
          }
        }
      case 3:
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
        case 2:
          let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = "Baixe o app exclusivo"
          cell.tag = 160
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
              cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)), placeholderImage: Image(named:"avatar.png"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            }
            cell.identifier = actualComments[indexPath.row].audio
            return cell
            
          }
          if actualComments[indexPath.row].postType == .Image {
            let cell = tableView.dequeueReusableCellWithIdentifier("wallImageCell", forIndexPath: indexPath) as! WallImageTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            
            cell.textViewWall.text = actualComments[indexPath.row].text
            if actualComments[indexPath.row].text == "" {
              cell.textViewWall.removeFromSuperview()
            }
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
                            cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)), placeholderImage: Image(named:"avatar.png"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            }
            cell.buttonZoomImage.tag = indexPath.row
            cell.tag = indexPath.row
            cell.imageAttachment.frame = CGRect(origin: CGPoint(x: cell.imageAttachment.frame.origin.x,y: cell.imageAttachment.frame.origin.y), size: CGSize(width: cell.frame.width, height: 200))
            //                        cell.heightImage.constant = 200
            //                        cell.widthImage.constant = cell.frame.width
            
            
            //cell.imageAttachment.image = cell.imageInCell
            if let image = sizesImage[indexPath]?.image {
              if let size = sizesImage[indexPath]?.size {
                if size.height > 5 {
                  //cell.imageAttachment.image = sizesImage[indexPath].image
                  let point = CGPoint(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y)
                  cell.imageAttachment.contentMode = .ScaleAspectFit
                  cell.imageAttachment.frame = CGRect(origin: point, size: size)
                  cell.imageAttachment.image = sizesImage[indexPath]?.image
                  //let ratio = (cell.imageInCell.size.height)/(cell.imageInCell.size.width)
                  //cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: ratio*cell.frame.width)
                  cell.heightImage.constant = self.sizesImage[indexPath]!.size.height
                }
              }
            } else {
              let userImage = NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualComments[indexPath.row].image))
              let resource = Resource(downloadURL: userImage!)
              cell.imageAttachment.kf_setImageWithResource(resource, placeholderImage: nil, optionsInfo: [], progressBlock: { (receivedSize, totalSize) in
                
                }, completionHandler: { (image, error, cacheType, imageURL) in
                  if let _ = error {
                    print("Error to reload image in cell \(indexPath.row)")
                  } else {
                    if cell.tag == indexPath.row {
                      
                      let ratio = (image!.size.height)/(image!.size.width)
                      let newHeight = ratio*cell.frame.width
                      cell.heightImage.constant = newHeight
                      cell.setNeedsLayout()
                      let imageWithSize = ImageWithSize(image: image, size: CGSize(width: cell.frame.width, height: newHeight))
                      self.sizesImage[indexPath] = imageWithSize
                      dispatch_async(dispatch_get_main_queue()) {
                        cell.heightImage.constant = ratio*cell.frame.width
                        cell.imageAttachment.layoutIfNeeded()
                        if indexPath == NSIndexPath(forRow: 0, inSection: 0) && !self.updateFistCell {
                          self.updateFistCell = true
                          tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                          
                        }
                      }
                    }
                  }
              })
              
              
            }
            
            cell.buttonZoomImage.backgroundColor = UIColor.clearColor()
            return cell

          } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("wallCell", forIndexPath: indexPath) as! WallTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            cell.textViewWall.text = actualComments[indexPath.row].text
            
            let contentSize = cell.textViewWall.sizeThatFits(cell.textViewWall.bounds.size)
            var frame = cell.textViewWall.frame
            frame.size.height = contentSize.height
            cell.heightText.constant = contentSize.height
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)), placeholderImage: Image(named:"avatar.png"), optionsInfo: nil, progressBlock: nil, completionHandler: nil)
            }
            return cell
          }
        } else {
          let cell = UITableViewCell()
          cell.tag = 999
          cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
          return cell
        }
      } else {
        let cell = UITableViewCell()
        cell.tag = 999
        return cell
      }
    }
  }
  
  
  
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch selectedMode {
    case .DetailRadio:
      switch section {
      case 0:
        return ""
      case 1:
        return "Ao vivo"
      case 2:
        return "Programa atual"
      case 3:
        return "Outros"
      case 4:
        if similarRadios.count == 0 {
          return ""
        } else {
          return "Rádios semelhantes"
        }
      default:
        return ""
      }
    default:
      return ""
    }
  }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    if let cell2 = cell as? WallImageTableViewCell {
      print(cell2.imageAttachment.frame)
    }
    let cellTag = (cell?.tag)!
    switch cellTag {
    case 110:
      performSegueWithIdentifier("reviewSegue", sender: self)
    case 120:
      DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: similarRadios[indexPath.row])
    case 130:
      performSegueWithIdentifier("contactSegue", sender: self)
    case 150:
      performSegueWithIdentifier("programSegue", sender: self)
    case 160:
      UIApplication.sharedApplication().openURL(NSURL(string: actualRadio.iosLink)!)
    default:
      break
    }
    if selectedMode == .Wall && tableView.cellForRowAtIndexPath(indexPath)?.tag != 999 {
      selectedComment = actualComments[indexPath.row]
      performSegueWithIdentifier("showSubCommentsSegue", sender: self)
    }
  }
  
  @IBAction func facebookButtonTap(sender: AnyObject) {
    if let url = NSURL(string: contactRadio.facebook) {
      UIApplication.sharedApplication().openURL(url)
    } else {
      self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(contactRadio.facebook)!", action: "Ok")
    }
  }
  
  @IBAction func instagramButtonTap(sender: AnyObject) {
    if let url = NSURL(string: contactRadio.instagram) {
      UIApplication.sharedApplication().openURL(url)
    } else {
      self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(contactRadio.instagram)!", action: "Ok")
    }
  }
  
  @IBAction func TwitterButtonTap(sender: AnyObject) {
    if let url = NSURL(string: contactRadio.twitter) {
      UIApplication.sharedApplication().openURL(url)
    } else {
      self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(contactRadio.twitter)!", action: "Ok")
    }
  }
  
  @IBAction func whatsAppButtonTap(sender: AnyObject) {
    
    let contactAuth = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
    switch contactAuth {
    case .Authorized:
      print("Contatos autorizados")
      var numberWhats = ""
      for number in contactRadio.phoneNumbers {
        if number.phoneType.name == "WhatsApp" {
          numberWhats = number.phoneNumber
        }
      }
      sendWhats(numberWhats)
    case .NotDetermined:
      contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (succeeded, err) in
        guard err == nil && succeeded else {
          print("Contatos autorizados")
          var numberWhats = ""
          for number in self.contactRadio.phoneNumbers {
            if number.phoneType.name == "WhatsApp" {
              numberWhats = number.phoneNumber
            }
          }
          self.sendWhats(numberWhats)
          return
        }
        if err != nil {
          Util.displayAlert(title: "Atenção", message: "Não foi possível acessar seus contatos! Permita este aplicativo nos ajustes do Dispositivo", action: "Ok")
        }
      })
    default:
      break
    }

  }
  
  func sendWhats(number:String) {
    var newPhone = ""
    
    for caracter in number.characters {
      switch caracter {
      case "0","1","2","3","4","5","6","7","8","9":
        let string = "\(caracter)"
        
        newPhone.appendContentsOf(string)
      default:
        print("Removed invalid character.")
      }
    }
    
    
    let auth = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
    
    switch auth {
    case .Denied:
      Util.displayAlert(self, title: "Atenção", message: "Não foi possivel criar uma conversa", action: "Ok")
    case .Authorized:
      let contact = CNMutableContact()
      contact.givenName = "Rádio \(actualRadio.name)"
      let phone = CNPhoneNumber(stringValue: newPhone)
      let phoneLabel = CNLabeledValue(label: CNLabelWork, value: phone)
      contact.phoneNumbers.append(phoneLabel)
      
      let predicate = CNContact.predicateForContactsMatchingName(actualRadio.name)
      let toFetch = [CNContactIdentifierKey]
      
      do {
        let contacts = try contactStore.unifiedContactsMatchingPredicate(predicate, keysToFetch: toFetch)
        if let fist = contacts.first {
          if let phoneCallURL:NSURL = NSURL(string: "whatsapp://send?abid=\(fist.identifier)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
              Util.displayAlert(self, title: "Atenção", message: "Rádio \(actualRadio.name) foi adicionada à sua agenda de contatos. Basta localizar para abrir a conversa", okTitle: "Procurar Contato", cancelTitle: "Cancelar", okAction: {
                application.openURL(phoneCallURL)
                }, cancelAction: {
                  self.dismissViewControllerAnimated(true, completion: {
                    
                  })
              })
            } else {
              Util.displayAlert(self, title: "Atenção", message: "Não foi possível localizar o aplicativo WhatsApp em seu dispositivo!", action: "Ok")
            }
          }
        } else {
          do {
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(contact, toContainerWithIdentifier: nil)
            try contactStore.executeSaveRequest(saveRequest)
            if let phoneCallURL:NSURL = NSURL(string: "whatsapp://send?abid=\(contact.identifier)") {
              let application:UIApplication = UIApplication.sharedApplication()
              if (application.canOpenURL(phoneCallURL)) {
                Util.displayAlert(self, title: "Atenção", message: "Rádio \(actualRadio.name)/ foi adicionada à sua agenda de contatos. Basta localizar para abrir a conversa", okTitle: "Procurar Contato", cancelTitle: "Cancelar", okAction: {
                  application.openURL(phoneCallURL)
                  }, cancelAction: {
                    self.dismissViewControllerAnimated(true, completion: {
                      
                    })
                })
                
                
              } else {
                Util.displayAlert(self, title: "Atenção", message: "Não foi possível abrir uma conversa de WhatsApp com este número atravês deste dispositivo", action: "Ok")
              }
            }
            //navigationController?.popViewControllerAnimated(true)
          } catch {
            Util.displayAlert(self, title: "Atenção", message: "Não foi possível abrir uma conversa de WhatsApp com este número atravês deste dispositivo", action: "Ok")
          }
        }
      } catch {
        Util.displayAlert(self, title: "Atenção", message: "Não foi possível abrir uma conversa de WhatsApp com este número atravês deste dispositivo", action: "Ok")
      }
      
    default:
      break
    }
    
    
  }
  
  @IBAction func buttonNLike(sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
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
      
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário fazer login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  @IBAction func buttonLike(sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      
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
      
      
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário fazer login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
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
                        
                        self.actualMusic = resultGracenote
                        var musicRadio = MusicRadio()
                        musicRadio.music = resultGracenote
                        musicRadio.radio = self.actualRadio
                        DataManager.sharedInstance.lastMusicRadio = musicRadio
                        if resultGracenote.coverArt != ""{
                          gracenote.downloadImageArt(resultGracenote.coverArt, completion: { (resultImg) in
                            dispatch_async(dispatch_get_main_queue()) {
                              if self.selectedMode == .DetailRadio {
                                cell?.imageMusic.image = resultImg
                                self.actualMusic.updateImage(resultImg)
                                DataManager.sharedInstance.lastMusicRadio.music.updateImage(resultImg)
                                
                              }
                            }
                            
                          })
                        }
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
    if existAudioChannel {
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
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartNoFill.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartNoFill.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
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
      str = "Clique em \"+\" e seja o primeiro a criar uma publicação no mural de  \(actualRadio.name)"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    if let _ = imageView.image {
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
    } else {
      return Util.imageResize(UIImage(named: "logo-pretaAbert.png")!, sizeChange: CGSize(width: 100, height: 100))
    }

  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    performSegueWithIdentifier("createPublicationSegue", sender: self)
  }
  
  @IBAction func adsButtonTap(sender: AnyObject) {
    
  }
  
  @IBAction func zoomImageButtonTap(sender: AnyObject) {
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as! WallImageTableViewCell
    if let _ = cell.imageAttachment.image {
      RadioTableViewController.selectedImageButton = cell.imageAttachment.image!
      let imageProvider: ImageProvider = PoorManProvider()
      let buttonAssets = CloseButtonAssets(normal: UIImage(named:"arrowWhite")!, highlighted: UIImage(named: "arrowWhite"))
      
      let configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets, backgroundColor: UIColor.blackColor())
      let imageViewer = ImageViewerController(imageProvider: imageProvider, configuration: configuration, displacedView: sender as! UIView)
      self.presentImageViewer(imageViewer)
    }
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