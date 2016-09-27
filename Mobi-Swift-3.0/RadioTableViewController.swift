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
    
    
    notificationCenter.addObserver(self, selector: #selector(PlayerViewController.updateIcons), name: "updateIcons", object: nil)
    let manager = RequestManager()
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    manager.getAudioChannelsFromRadio(actualRadio) { (result) in
    }
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    //viewTop.backgroundColor = DataManager.sharedInstance.interfaceColor.color.colorWithAlphaComponent(0.7)

    
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    let color = ColorRealm(name: 2, red: components[0]-0.75, green: components[1]-0.75, blue: components[2]-0.75, alpha: 1)
    

    navigationController?.navigationBar.backgroundColor = color.color
    
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = true
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    switch selectedMode {
    case .DetailRadio:
      return 4
    default:
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .DetailRadio:
      if section == 3 {
        return DataManager.sharedInstance.favoriteRadios.count
      } else {
        return 1
      }
    default:
      return 0
    }
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
        cell.labelListening.text = "-"
        if !actualRadio.isFavorite {
          cell.imageHeart.image = UIImage(named: "heart.png")
        } else {
          cell.imageHeart.image = UIImage(named: "heartRed.png")
        }
//        if StreamingRadioManager.sharedInstance.currentlyPlaying() && StreamingRadioManager.sharedInstance.isRadioInViewCurrentyPlaying(actualRadio) {
//          buttonActionNav.image =  Util.imageResize(UIImage(named: "pause.png")!, sizeChange: CGSize(width: 20, height: 20))
//        } else {
//          buttonActionNav.image =  Util.imageResize(UIImage(named: "play.png")!, sizeChange: CGSize(width: 20, height: 20))
//        }
        return cell
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("actualMusic", forIndexPath: indexPath) as! MusicTableViewCell
        cell.labelMusicName.text = "Happy"
        cell.labelAlbum.text = "G I R L"
        cell.labelArtist.text = "Pharell Willians"
        cell.buttonNLike.backgroundColor = UIColor.clearColor()
        cell.butonLike.backgroundColor = UIColor.clearColor()
        cell.imageMusic.image = UIImage(named: "happy.jpg")
        return cell
      case 2:
        let cell = tableView.dequeueReusableCellWithIdentifier("actualProgram", forIndexPath: indexPath) as! ActualProgramTableViewCell
        cell.labelName.text = "Programa da Manha"
        cell.labelSchedule.text = "10:00 - 11:00"
        cell.imagePerson.image = UIImage(named: "happy.jpg")
        cell.imagePerson.layer.cornerRadius = cell.imagePerson.bounds.height / 2
        cell.imagePerson.layer.borderColor = UIColor.blackColor().CGColor
        cell.imagePerson.layer.borderWidth = 0
        cell.imagePerson.clipsToBounds = true
        cell.labelNamePerson.text = "Marcos"
        cell.labelGuests.text = "Toninho e Fulanhinho de tal"
        return cell
      case 3:
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
          return cell
      default:
        let cell = UITableViewCell()
        return cell
      }
    default:
      let cell = UITableViewCell()
      return cell
    }
    
    let cell = UITableViewCell()
    
    // Configure the cell... actualMusic detailRadio actualProgram
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
      default:
        return ""
      }
    default:
      return ""
    }
  }
  
//  override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//    switch selectedMode {
//    case .DetailRadio:
//      switch indexPath.section {
//      case 0:
//        return super
//      case 1:
//        <#code#>
//      case 2:
//        <#code#>
//      case 3:
//        <#code#>
//      default:
//        <#code#>
//      }
//    default:
//      <#code#>
//    }
//  }
  
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
