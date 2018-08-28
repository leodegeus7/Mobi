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


class RadioTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,GalleryItemsDataSource {
  
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
  let notificationCenter = NotificationCenter.default
  var selectedMode:SelectedRadioMode = .detailRadio
  var colorBlack : UIColor!
  var colorWhite : UIColor!
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  var contactRadio = ContactRadio()
  var needToUpdateCell = false
  var needToUpdateIcons = false
  
  var avAudioPlayer:AVAudioPlayer!
  
  var updateFistCell = false
  var contactStore = CNContactStore()
  static var selectedImageButton:UIImage!
  
  var existAudioChannel = false
  
  enum SelectedRadioMode {
    case detailRadio
    case wall
  }
  
  
  struct ImageWithSize {
    var image:UIImage!
    var size:CGSize!
  }
  
  var sizesImage = Dictionary<IndexPath,ImageWithSize>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- VARIABLE SET ---
    ///////////////////////////////////////////////////////////
    
    let button = UIButton(type: UIButtonType.infoLight)
    buttonActionNav = UIBarButtonItem.init(customView: button)
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: NSNotification.Name(rawValue: "updateIcons"), object: nil)
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    
    tableView.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    selectedMode == .detailRadio
    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.15, green: (components?[1])!+0.15, blue: (components?[2])!+0.15, alpha: 1).color
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    self.clearsSelectionOnViewWillAppear = true
    
    self.navigationController? .setNavigationBarHidden(false, animated:true)
    let backButton = UIButton(type: UIButtonType.custom)
    backButton.addTarget(self, action: #selector(RadioTableViewController.backFunction), for: UIControlEvents.touchUpInside)
    backButton.setTitle("< Voltar", for: UIControlState())
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
      if self.selectedMode == .detailRadio {
        self.tableView.reloadSections(IndexSet(integer: 4), with: .automatic)
      }
    }
    
    let scoreRequest = RequestManager()
    scoreRequest.getRadioScore(actualRadio) { (resultScore) in
      if self.selectedMode == .detailRadio {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RadioDetailTableViewCell {
          
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
        self.activityIndicator.isHidden = true
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
        if self.selectedMode == .detailRadio {
          self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
      })
    }
    
    
    let programRequest = RequestManager()
    let idRadio = actualRadio.id
    programRequest.requestActualProgramOfRadio(idRadio) { (resultProgram) in
      self.actualProgram = resultProgram
      
      DispatchQueue.main.async(execute: {
        if self.selectedMode == .detailRadio {
          self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
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
  
  override func viewWillAppear(_ animated: Bool) {
    defineBarButton()
    
  }
  
  func backFunction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  

  override func numberOfSections(in tableView: UITableView) -> Int {
    switch selectedMode {
    case .detailRadio:
      return 5
    case .wall:
      return 1
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .detailRadio:
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
          return 4
        } else {
          return 3
        }
      } else {
        return 1
      }
    case .wall:
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
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.imageView?.kf.cancelDownloadTask()
    
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.clearsSelectionOnViewWillAppear = true
    if let _ = tableView.indexPathForSelectedRow {
      let index = self.tableView.indexPathForSelectedRow
      self.tableView.deselectRow(at: index!, animated: true)
    }
    
  }
  
  override func viewDidLayoutSubviews() {
    if selectedMode == .detailRadio {
      if let cellDetail = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
        cellDetail.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: cellDetail.frame, andColors: [colorWhite,colorBlack])
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch selectedMode {
    case .detailRadio:
      switch indexPath.section {
      case 0:
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "detailRadio", for: indexPath) as! RadioDetailTableViewCell
          cell.imageRadio.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
          cell.imageRadio.layer.cornerRadius = cell.imageRadio.bounds.height / 6
          cell.imageRadio.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.cgColor
          cell.imageRadio.layer.backgroundColor = UIColor.white.cgColor
          cell.imageRadio.layer.borderWidth = 0
          cell.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: cell.frame, andColors: [colorWhite,colorBlack])
          cell.labelName.text = actualRadio.name.uppercased()
          cell.labelName.textColor = UIColor.white
          if let _ = actualRadio.address {
            cell.labelLocal.text = actualRadio.address.formattedLocal.uppercased()
            cell.labelLocal.textColor = UIColor.white
          }
          cell.labelLikes.text = "\(actualRadio.likenumber)"
          cell.labelLikes.textColor = UIColor.white
          if actualRadio.score == -1 {
            cell.labelScore.text = "-"
          } else {
            cell.labelScore.text = "\(actualRadio.score)"
          }
          cell.labelScore.textColor = UIColor.white
          cell.labelLikesDescr.textColor = UIColor.white
          cell.labelScoreDescr.textColor = UIColor.white
          cell.viewBack.alpha = 0
          cell.playButton.backgroundColor = UIColor.clear
          cell.playButton.layer.cornerRadius = cell.playButton.bounds.height / 2
          cell.imageRadio.layer.borderWidth = 0
          cell.imageRadio.clipsToBounds = true
          cell.selectionStyle = .none
          cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
          if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
            cell.playButton.setImage(UIImage(named: "pause.png"), for: UIControlState())
          } else {
            cell.playButton.setImage(UIImage(named: "play1.png"), for: UIControlState())
          }
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "socialNetCell", for: indexPath) as! SocialNetworkTableViewCell
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
          cell.selectionStyle = .none
          return cell
        }
      case 1:
        let cell = tableView.dequeueReusableCell(withIdentifier: "actualMusic", for: indexPath) as! MusicTableViewCell
        if let _ = actualMusic.name {
          cell.labelMusicName.text = actualMusic.name
          cell.labelArtist.text = actualMusic.composer
        }
        else {
          cell.labelMusicName.text = "Musica"
          cell.labelArtist.text = "Artista"
        }
        cell.buttonNLike.backgroundColor = UIColor.clear
        cell.buttonLike.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        if !cellMusicIsShowed {
          cell.loadInfo()
          cellMusicIsShowed = true
        }
        return cell
      case 2:
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "actualProgram", for: indexPath) as! ActualProgramTableViewCell
          cell.tag = 150
          if actualProgram.id == -1 {
            cell.lockView()
            return cell
          } else {
            if type(of: actualProgram) == SpecialProgram.self {
              let programSpecial2 = actualProgram as! SpecialProgram
              cell.labelName.text = actualProgram.name
              cell.labelSecondName.text = ""
              let identifierImage = actualProgram.announcer.userImage
              cell.imagePerson.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
              cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
              cell.imagePerson.layer.borderColor = UIColor.black.cgColor
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
              cell.imagePerson.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(identifierImage)))
              cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
              cell.imagePerson.layer.borderColor = UIColor.black.cgColor
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
          let cell = tableView.dequeueReusableCell(withIdentifier: "adsCell", for: indexPath) as! AdsTableViewCell
          let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
          let colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.1, green: (components?[1])!+0.1, blue: (components?[2])!+0.1, alpha: 0.2).color
          cell.adsButton.backgroundColor = colorWhite
          cell.adsButton.setBackgroundImage(UIImage(named: "logoAnuncio.png"), for: UIControlState())
          cell.selectionStyle = .none
          
          print("Tamanho do adbutton \(cell.adsButton.frame.size)")
          AdsManager.sharedInstance.setAdvertisement(.playerScreen, completion: { (resultAd) in
            DispatchQueue.main.async {
              if let imageAd = resultAd.image {
                let imageView = UIImageView(frame: cell.adsButton.frame)
                imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
                cell.adsButton.setBackgroundImage(imageView.image, for: UIControlState())
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
            cell.labelName.text = similarRadios[indexPath.row].name
            if let address = similarRadios[indexPath.row].address {
              cell.labelLocal.text = address.formattedLocal
            }
            cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(similarRadios[indexPath.row].thumbnail)))
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
            cell.labelReadMore.text = "Ver Mais"
            cell.tag = 140
            return cell
          }
        } else {
          if indexPath.row <= similarRadios.count-1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
            cell.labelName.text = similarRadios[indexPath.row].name
            if let address = similarRadios[indexPath.row].address {
              cell.labelLocal.text = address.formattedLocal
            }
            cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(similarRadios[indexPath.row].thumbnail)))
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
            cell.selectionStyle = .none
            return cell
          }
        }
      case 3:
        switch indexPath.row {
        case 0:
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = "Avaliações"
          cell.tag = 110
          return cell
        case 1:
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = "Contato"
          cell.tag = 130
          return cell
        case 2:
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = "Compartilhar"
          cell.tag = 170
          return cell
        case 3:
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
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
    case .wall :
      if !firstTimeShowed {
        if indexPath.row <= actualComments.count-1 {
          if actualComments[indexPath.row].postType == .audio {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallAudioCell", for: indexPath) as! WallAudioPlayerTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            cell.textViewWall.text = actualComments[indexPath.row].text
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)), placeholder: Image(named:"avatar.png"), options: nil, progressBlock: nil, completionHandler: nil)
            }
            cell.identifier = actualComments[indexPath.row].audio
            return cell
            
          }
          if actualComments[indexPath.row].postType == .image {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallImageCell", for: indexPath) as! WallImageTableViewCell
            cell.labelName.text = actualComments[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualComments[indexPath.row].date)
            
            cell.textViewWall.text = actualComments[indexPath.row].text
            if actualComments[indexPath.row].text == "" {
              cell.textViewWall.removeFromSuperview()
            }
            if actualComments[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
                            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)), placeholder: Image(named:"avatar.png"), options: nil, progressBlock: nil, completionHandler: nil)
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
                  cell.imageAttachment.contentMode = .scaleAspectFit
                  cell.imageAttachment.frame = CGRect(origin: point, size: size)
                  cell.imageAttachment.image = sizesImage[indexPath]?.image
                  //let ratio = (cell.imageInCell.size.height)/(cell.imageInCell.size.width)
                  //cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: ratio*cell.frame.width)
                  cell.heightImage.constant = self.sizesImage[indexPath]!.size.height
                }
              }
            } else {
              let userImage = URL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualComments[indexPath.row].image))
                
              let resource = ImageResource(downloadURL: userImage!)
                cell.imageAttachment.kf.setImage(with: resource, placeholder: nil, options: [], progressBlock: { (receivedSize, totalSize) in
                    
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

                            DispatchQueue.main.async {
                                cell.heightImage.constant = ratio*cell.frame.width
                                cell.imageAttachment.layoutIfNeeded()
                                
                                if indexPath == IndexPath(row: 0, section: 0) && !self.updateFistCell {
                                    self.updateFistCell = true
                                    tableView.reloadRows(at: [indexPath], with: .automatic)
                                    
                                }
                            }
                        }
                    }
                })
                
                

              
              
            }
            
            cell.buttonZoomImage.backgroundColor = UIColor.clear
            return cell

          } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "wallCell", for: indexPath) as! WallTableViewCell
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
              cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComments[indexPath.row].user.userImage)), placeholder: Image(named:"avatar.png"), options: nil, progressBlock: nil, completionHandler: nil)
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
  
  
  
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch selectedMode {
    case .detailRadio:
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
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let cell = tableView.cellForRow(at: indexPath)
    if let cell2 = cell as? WallImageTableViewCell {
      print(cell2.imageAttachment.frame)
    }
    let cellTag = (cell?.tag)!
    switch cellTag {
    case 110:
      performSegue(withIdentifier: "reviewSegue", sender: self)
    case 120:
      DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: similarRadios[indexPath.row])
    case 130:
      performSegue(withIdentifier: "contactSegue", sender: self)
    case 150:
      performSegue(withIdentifier: "programSegue", sender: self)
    case 160:
      UIApplication.shared.openURL(URL(string: actualRadio.iosLink)!)
    case 170:
      let message = "Escute a \(actualRadio.name) no MobiAbert. Ainda não tem o app? Então baixe aqui http://onelink.to/mobiabert"
      let link:URL = URL(string: "http://onelink.to/mobiabert")!
      let activityView = UIActivityViewController(activityItems: [message,link], applicationActivities: nil)
      self.present(activityView, animated: true, completion: {
        
      })
    default:
      break
    }
    if selectedMode == .wall && tableView.cellForRow(at: indexPath)?.tag != 999 {
      selectedComment = actualComments[indexPath.row]
      performSegue(withIdentifier: "showSubCommentsSegue", sender: self)
    }
  }
  
  @IBAction func facebookButtonTap(_ sender: AnyObject) {
    if let url = URL(string: contactRadio.facebook) {
      UIApplication.shared.openURL(url)
    } else {
      self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(contactRadio.facebook)!", action: "Ok")
    }
  }
  
  @IBAction func instagramButtonTap(_ sender: AnyObject) {
    if let url = URL(string: contactRadio.instagram) {
      UIApplication.shared.openURL(url)
    } else {
      self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(contactRadio.instagram)!", action: "Ok")
    }
  }
  
  @IBAction func TwitterButtonTap(_ sender: AnyObject) {
    if let url = URL(string: contactRadio.twitter) {
      UIApplication.shared.openURL(url)
    } else {
      self.displayAlert(title: "Atenção", message: "Não foi possível abrir a página \(contactRadio.twitter)!", action: "Ok")
    }
  }
  
  @IBAction func whatsAppButtonTap(_ sender: AnyObject) {
    
    let contactAuth = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    switch contactAuth {
    case .authorized:
      print("Contatos autorizados")
      var numberWhats = ""
      for number in contactRadio.phoneNumbers {
        if number.phoneType.name == "WhatsApp" {
          numberWhats = number.phoneNumber
        }
      }
      sendWhats(numberWhats)
    case .denied:
      Util.displayAlert(title: "Atenção", message: "Permita os Contatos nos ajustes do dispositivo", action: "Ok")
    case .notDetermined:
      contactStore.requestAccess(for: .contacts, completionHandler: { (succeeded, err) in
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
  
  func sendWhats(_ number:String) {
    var newPhone = ""
    
    for caracter in number.characters {
      switch caracter {
      case "0","1","2","3","4","5","6","7","8","9":
        let string = "\(caracter)"
        
        newPhone.append(string)
      default:
        print("Removed invalid character.")
      }
    }
    
    
    let auth = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    
    switch auth {
    case .denied:
      Util.displayAlert(self, title: "Atenção", message: "Não foi possivel criar uma conversa", action: "Ok")
    case .authorized:
      let contact = CNMutableContact()
      contact.givenName = "Rádio \(actualRadio.name)"
      let phone = CNPhoneNumber(stringValue: newPhone)
      let phoneLabel = CNLabeledValue(label: CNLabelWork, value: phone)
      contact.phoneNumbers.append(phoneLabel)
      
      let predicate = CNContact.predicateForContacts(matchingName: actualRadio.name)
      let toFetch = [CNContactIdentifierKey]
      
      do {
        let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: toFetch as [CNKeyDescriptor])
        if let fist = contacts.first {
          if let phoneCallURL:URL = URL(string: "whatsapp://send?abid=\(fist.identifier)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
              Util.displayAlert(self, title: "Atenção", message: "Rádio \(actualRadio.name) foi adicionada à sua agenda de contatos. Basta localizar para abrir a conversa", okTitle: "Procurar Contato", cancelTitle: "Cancelar", okAction: {
                application.openURL(phoneCallURL)
                }, cancelAction: {
                  self.dismiss(animated: true, completion: {
                    
                  })
              })
            } else {
              Util.displayAlert(self, title: "Atenção", message: "Não foi possível localizar o aplicativo WhatsApp em seu dispositivo!", action: "Ok")
            }
          }
        } else {
          do {
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try contactStore.execute(saveRequest)
            if let phoneCallURL:URL = URL(string: "whatsapp://send?abid=\(contact.identifier)") {
              let application:UIApplication = UIApplication.shared
              if (application.canOpenURL(phoneCallURL)) {
                Util.displayAlert(self, title: "Atenção", message: "Rádio \(actualRadio.name)/ foi adicionada à sua agenda de contatos. Basta localizar para abrir a conversa", okTitle: "Procurar Contato", cancelTitle: "Cancelar", okAction: {
                  application.openURL(phoneCallURL)
                  }, cancelAction: {
                    self.dismiss(animated: true, completion: {
                      
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
  
  @IBAction func buttonNLike(_ sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
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
  @IBAction func buttonLike(_ sender: AnyObject) {
    if DataManager.sharedInstance.isLogged {
      
      let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
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
  
  func setButtonMusicType(_ music:Music) {
    if selectedMode == .detailRadio {
      let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
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
  
  @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
    switch segmentedMenu.selectedSegmentIndex {
    case 0:
      selectedMode = .detailRadio
    case 1:
      selectedMode = .wall
      view.addSubview(activityIndicator)
      activityIndicator.isHidden = false
      tableView.allowsSelection = false
      let requestManager = RequestManager()
      requestManager.requestWallOfRadio(actualRadio, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
        self.actualComments = resultWall
        self.firstTimeShowed = false
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.self.activityIndicator.removeFromSuperview()
        self.tableView.reloadData()
      })
    default:
      selectedMode = .detailRadio
    }
    defineBarButton()
    tableView.reloadData()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHER FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  func reloadCell(_ indexPathTest:IndexPath) {
    if selectedMode == .wall {
      
      tableView.reloadRows(at: [indexPathTest], with: .none)
      
    }
  }
  
  
  func updateInterfaceWithGracenote() {
    if let audioChannel = actualRadio.audioChannels.first {
      if audioChannel.existRdsLink {
        let rdsRequest = RequestManager()
        rdsRequest.downloadRdsInfo((actualRadio.audioChannels.first?.linkRds.link)!) { (result) in
          if let resultTest = result[true] {
            if resultTest.existData {

                
                DispatchQueue.main.async(execute: {
                    var musicRadio = MusicRadio()
                    musicRadio.music = Music(id: "", name: resultTest.title, albumName: "", composer: resultTest.artist, coverArt: "")
                    musicRadio.radio = self.actualRadio
                    
                    
                    if musicRadio.music.name != "" {
                        if self.selectedMode == .detailRadio {
                            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
                            cell?.unlockContent()
                            cell?.labelMusicName.text = musicRadio.music.name
                            cell?.labelArtist.text = musicRadio.music.composer
                            self.setButtonMusicType(musicRadio.music)
                            
                            self.actualMusic = musicRadio.music
                            DataManager.sharedInstance.lastMusicRadio = musicRadio

                        }
                        
                    } else {
                        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
                        cell?.lockContent()
                    }
                })
                
              
            } else {
              let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
              cell?.lockContent()
            }
          } else {
            let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
            cell?.lockContent()
          }
        }
      } else {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
        cell?.lockContent()
      }
    } else {
      let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? MusicTableViewCell
      cell?.lockContent()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "programSegue" {
      let programTV = (segue.destination as! ProgramsTableViewController)
      programTV.actualRadio = actualRadio
    }
    if segue.identifier == "reviewSegue" {
      let reviewVC = segue.destination as! ReviewTableViewController
      reviewVC.actualRadio = actualRadio
    }
    if segue.identifier == "createPublicationSegue" {
      let createVC = segue.destination as! SendPublicationViewController
      createVC.actualRadio = actualRadio
      createVC.actualMode = .wall
    }
    if segue.identifier == "showSubCommentsSegue" {
      let createVC = segue.destination as! CommentsTableViewController
      createVC.actualRadio = actualRadio
      createVC.actualComment = selectedComment
    }
    if segue.identifier == "contactSegue" {
      let contactVC = segue.destination as! ContactRadioTableViewController
      contactVC.actualRadio = actualRadio
    }
  }
  
  @IBAction func buttonPlayTapped(_ sender: AnyObject) {
    if existAudioChannel {
      if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
        if StreamingRadioManager.sharedInstance.currentlyPlaying() {
          StreamingRadioManager.sharedInstance.stop()
        } else {
          StreamingRadioManager.sharedInstance.play(actualRadio)
          DataManager.sharedInstance.miniPlayerView.miniPlayerView.isHidden = false
          DataManager.sharedInstance.miniPlayerView.tapMiniPlayerButton(DataManager.sharedInstance.miniPlayerView)
        }
      } else {
        StreamingRadioManager.sharedInstance.play(actualRadio)
        DataManager.sharedInstance.miniPlayerView.miniPlayerView.isHidden = false
        DataManager.sharedInstance.miniPlayerView.tapMiniPlayerButton(DataManager.sharedInstance.miniPlayerView)
      }
      StreamingRadioManager.sharedInstance.sendNotification()
    }
  }
  
  func updateIcons() {
    if let cellFirst = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RadioDetailTableViewCell {
      
      if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
        if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
          cellFirst.playButton.setImage(UIImage(named: "pause.png"), for: UIControlState())
        } else {
          cellFirst.playButton.setImage(UIImage(named: "play1.png"), for: UIControlState())
        }
      } else {
        cellFirst.playButton.setImage(UIImage(named: "play1.png"), for: UIControlState())
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
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartNoFill.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      actualRadio.updateIsFavorite(false)
      let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? RadioDetailTableViewCell
      if let _ = cell {
        cell?.labelLikes.text = "\(Int((cell?.labelLikes.text)!)! - 1)"
        self.actualRadio.removeOneLikesNumber()
      }
      manager.deleteFavRadio(actualRadio, completion: { (result) in
      })
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartRedFilled.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      actualRadio.updateIsFavorite(true)
      let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? RadioDetailTableViewCell
      if let _ = cell {
        cell?.labelLikes.text = "\(Int((cell?.labelLikes.text)!)! + 1)"
        self.actualRadio.addOneLikesNumber()
      }
      manager.favRadio(actualRadio, completion: { (resultFav) in
      })
    }
  }
  
  func createComment() {
    if DataManager.sharedInstance.isLogged {
      performSegue(withIdentifier: "createPublicationSegue", sender: self)
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
    if selectedMode == .detailRadio {
      if !actualRadio.isFavorite {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartNoFill.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartRedFilled.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
      }
    } else if selectedMode == .wall {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "plus.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RadioTableViewController.createComment))
      
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .wall {
      str = "Nenhuma publicação realizada no mural"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if selectedMode == .wall {
      str = "Clique em \"+\" e seja o primeiro a criar uma publicação no mural de  \(actualRadio.name)"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    if let _ = imageView.image {
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
    } else {
      return Util.imageResize(UIImage(named: "logo-pretaAbert.png")!, sizeChange: CGSize(width: 100, height: 100))
    }

  }
  
  func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
    performSegue(withIdentifier: "createPublicationSegue", sender: self)
  }
  
  @IBAction func adsButtonTap(_ sender: AnyObject) {
    
  }
  
  @IBAction func zoomImageButtonTap(_ sender: AnyObject) {
    let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! WallImageTableViewCell
    if let image = cell.imageAttachment.image {
      RadioTableViewController.selectedImageButton = cell.imageAttachment.image!
        selectedImage = image
        self.presentImageGallery(GalleryViewController(startIndex: 0, itemsDataSource: self))


    }
  }
    
    var selectedImage = UIImage()
    
    func itemCount() -> Int {
        return 1
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return GalleryItem.image(fetchImageBlock: { (completion) in
            completion(self.selectedImage)
        })
    }
}

