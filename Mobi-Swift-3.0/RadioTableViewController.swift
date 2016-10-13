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
  var selectedRadio = RadioRealm()
  var actualRadio = RadioRealm()
  var stars = [UIImageView]()
  var actualComments = [Comment]()
  var similarRadios = [RadioRealm]()
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var selectedMode:SelectedRadioMode = .DetailRadio
  var colorBlack : UIColor!
  var colorWhite : UIColor!
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
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
    }
    
    let similarRequest = RequestManager()
    similarRequest.requestSimilarRadios(0, pageSize: 20, radioToCompare: actualRadio) { (resultSimilar) in
      self.similarRadios = resultSimilar
      self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
    }
    
    let scoreRequest = RequestManager()
    scoreRequest.getRadioScore(actualRadio) { (resultScore) in
      let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! RadioDetailTableViewCell
      if self.actualRadio.score == -1 {
        cell.labelScore.text = "-"
      } else {
        cell.labelScore.text = "\(self.actualRadio.score)"
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
      if section == 3 {
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
        return actualComments.count
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
        cell.imageRadio.layer.borderWidth = 1
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
        if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
          cell.playButton.setImage(UIImage(named: "pause.png"), forState: .Normal)
        } else {
          cell.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
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
      } else {
        let cell = UITableViewCell()
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "programSegue" {
      let programTV = (segue.destinationViewController as! ProgramsTableViewController)
      programTV.actualRadio = actualRadio
    }
    if segue.identifier == "reviewSegue" {
      let reviewVC = segue.destinationViewController as! ReviewTableViewController
      reviewVC.actualRadio = actualRadio
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
        cellFirst.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
      }
    } else {
      cellFirst.playButton.setImage(UIImage(named: "play1.png"), forState: .Normal)
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
  
  func createComment() {
    performSegueWithIdentifier("createCommentSegue", sender: self)
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
    dismissViewControllerAnimated(true) {
    }
  }
}