//
//  RadioTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/27/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

class RadioTableViewController: UITableViewController {
  
  @IBOutlet weak var buttonActionNav: UIBarButtonItem!
  
  //@IBOutlet weak var segmentedMenu: UISegmentedControl!
  @IBOutlet weak var segmentedMenu: UISegmentedControl!
  @IBOutlet weak var viewTop: UIView!
  
  var actualRadio = RadioRealm()
  var stars = [UIImageView]()
  
  var similarRadios = [RadioRealm]()
  
  let notificationCenter = NSNotificationCenter.defaultCenter()
  
  enum SelectedRadioMode {
    case DetailRadio
    case Wall
    case Programs
    case Contact
  }
  var selectedMode:SelectedRadioMode = .DetailRadio
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let button = UIButton(type: UIButtonType.InfoLight)
    buttonActionNav = UIBarButtonItem.init(customView: button)
    similarRadios = DataManager.sharedInstance.favoriteRadios
    
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)
    let manager = RequestManager()
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    manager.getAudioChannelsFromRadio(actualRadio) { (result) in
    }
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    //viewTop.backgroundColor = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.7)
    
    
    
    
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  
  override func viewWillAppear(animated: Bool) {
    if !actualRadio.isFavorite {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heart.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "heartRedFilled.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.buttonFavTap))
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    switch selectedMode {
    case .DetailRadio:
      return 5
    default:
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .DetailRadio:
      if section == 3 {
        if similarRadios.count <= 3 {
          return similarRadios.count
        } else {
          return similarRadios.count + 1
        }
      } else if section == 4 {
        return 3
      } else {
        return 1
      }
    default:
      return 0
    }
    return 0
  }
  
  @IBAction func segmentedControlChanged(sender: UISegmentedControl) {
    switch segmentedMenu.selectedSegmentIndex {
    case 0:
      selectedMode = .DetailRadio
    case 1:
      selectedMode = .Wall
    case 2:
      selectedMode = .Programs
    case 3:
      selectedMode = .Contact
    default:
      selectedMode = .DetailRadio
    }
    tableView.reloadData()
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
        cell.imageRadio.layer.borderWidth = 1
        let colorAlpha = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.7)
        cell.backgroundColor = colorAlpha
        cell.labelName.text = actualRadio.name
        if let _ = actualRadio.address {
          cell.labelLocal.text = actualRadio.address.formattedLocal
        }
        cell.labelLikes.text = "\(actualRadio.likenumber)"
        cell.labelScore.text = "\(actualRadio.stars)"
        
        
        
        
        
        cell.viewBack.alpha = 0
        //cell.viewBack.backgroundColor = color.color
        let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
        let colorBlack =  ColorRealm(name: 45, red: components[0]-0.1, green: components[1]-0.1, blue: components[2]-0.1, alpha: 1).color
        cell.playButton.backgroundColor = colorBlack
        cell.playButton.layer.cornerRadius = cell.playButton.bounds.height / 2
        cell.imageRadio.layer.borderWidth = 0
        cell.imageRadio.clipsToBounds = true
        if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
          cell.playButton.setImage(UIImage(named: "pause.png"), forState: .Normal)
        } else {
          cell.playButton.setImage(UIImage(named: "play.png"), forState: .Normal)
        }
        
        
        return cell
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("actualMusic", forIndexPath: indexPath) as! MusicTableViewCell
        cell.labelMusicName.text = "Happy"
        cell.labelArtist.text = "Pharell Willians"
        cell.buttonNLike.backgroundColor = UIColor.clearColor()
        cell.butonLike.backgroundColor = UIColor.clearColor()
        cell.imageMusic.image = UIImage(named: "happy.jpg")
        return cell
      case 2:
        let cell = tableView.dequeueReusableCellWithIdentifier("actualProgram", forIndexPath: indexPath) as! ActualProgramTableViewCell
        cell.labelName.text = "Programa da Manha"
        cell.labelSecondName.text = "Programa Matutino"
        cell.imagePerson.image = UIImage(named: "happy.jpg")
        cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
        cell.imagePerson.layer.borderColor = UIColor.blackColor().CGColor
        cell.imagePerson.layer.borderWidth = 0
        cell.imagePerson.clipsToBounds = true
        cell.labelNamePerson.text = "Marcos"
        cell.labelGuests.text = "Toninho e Fulanhinho de tal"
        cell.tag = 150
        return cell
      case 3:
        if indexPath.row <= DataManager.sharedInstance.favoriteRadios.count-1 {
          let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
          cell.labelName.text = DataManager.sharedInstance.favoriteRadios[indexPath.row].name
          if let address = DataManager.sharedInstance.favoriteRadios[indexPath.row].address {
            cell.labelLocal.text = address.formattedLocal
          }
          cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.favoriteRadios[indexPath.row].thumbnail)))
          cell.labelDescriptionOne.text = "\(DataManager.sharedInstance.favoriteRadios[indexPath.row].likenumber)"
          cell.widthTextOne.constant = 30
          cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
          cell.labelDescriptionTwo.text = ""
          if DataManager.sharedInstance.favoriteRadios[indexPath.row].isFavorite {
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
    default:
      let cell = UITableViewCell()
      return cell
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
    let cellFirst = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RadioDetailTableViewCell
    if (StreamingRadioManager.sharedInstance.currentlyPlaying()) {
      if (StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio)) {
        cellFirst.playButton.setImage(UIImage(named: "pause.png"), forState: .Normal)
      } else {
        cellFirst.playButton.setImage(UIImage(named: "play.png"), forState: .Normal)
      }
    } else {
      cellFirst.playButton.setImage(UIImage(named: "play.png"), forState: .Normal)
    }
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
  
  
}
