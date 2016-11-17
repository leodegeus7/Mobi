//
//  RadioListTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/19/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class RadioListTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VARIABLE SET ---
  ///////////////////////////////////////////////////////////
  
  var radios = [RadioRealm]()
  var selectedRadio = RadioRealm()
  var superSegue = String()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- VARIABLE SET ---
    ///////////////////////////////////////////////////////////
    
    tableView.rowHeight = 120
    if radios.count > 0 {
      if superSegue == "detailGenre" {
        self.title = radios[0].genre
      } else if superSegue == "detailCity" {
        self.title = radios[0].address.city
      }
    }
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLEVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return radios.count + 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row <= DataManager.sharedInstance.allStates.count-1 {
      let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
      cell.labelName.text = radios[indexPath.row].name
      cell.labelLocal.text = radios[indexPath.row].address.formattedLocal
      cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(radios[indexPath.row].thumbnail)))
      if radios[indexPath.row].isFavorite {
        cell.imageSmallOne.image = UIImage(named: "heartRed.png")
      } else {
        cell.imageSmallOne.image = UIImage(named: "heart.png")
      }
      cell.labelDescriptionOne.text = "\(radios[indexPath.row].likenumber)"
      cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
      cell.labelDescriptionTwo.text = ""
      return cell
    } else {
      let cell = UITableViewCell()
      cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedRadio = radios[indexPath.row]
    performSegueWithIdentifier("detailRadio2", sender: self)
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    if radios[indexPath.row].isFavorite {
      let favorite = UITableViewRowAction(style: .Normal, title: "Desfavoritar") { action, index in
        self.radios[indexPath.row].updateIsFavorite(false)
        self.radios[indexPath.row].removeOneLikesNumber()
        manager.deleteFavRadio(self.radios[indexPath.row], completion: { (result) in
          manager.requestUserFavorites({ (resultFav) in
          })
        })
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      }
      favorite.backgroundColor = UIColor.orangeColor()
      return [favorite]
    } else {
      let favorite = UITableViewRowAction(style: .Normal, title: "Favoritar") { action, index in
        self.radios[indexPath.row].updateIsFavorite(true)
        self.radios[indexPath.row].addOneLikesNumber()
        manager.favRadio(self.radios[indexPath.row], completion: { (result) in
          self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        })
      }
      favorite.backgroundColor = UIColor.orangeColor()
      return [favorite]
    }
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  }
  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- OTHER FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailRadio2" {
      let radioVC = (segue.destinationViewController as! RadioTableViewController)
      radioVC.actualRadio = selectedRadio
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem registros"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if superSegue == "detailGenre" {
      str = "Não foi possivel localizar nenhuma rádio com este gênero"
    } else if superSegue == "detailCity" {
      str = "Não foi possível localizar nenhuma rádio com este local"
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "logo-pretaAbert.png")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    dismissViewControllerAnimated(true) {
    }
  }
  
  
}
