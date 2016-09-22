//
//  FavoriteTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/15/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class FavoriteTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  var selectedRadio = RadioRealm()
  override func viewDidLoad() {
    super.viewDidLoad()
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    tableView.rowHeight = 120
    self.title = "Radios Favoritas"
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func viewWillAppear(animated: Bool) {
    
    let manager = RequestManager()
    manager.requestUserFavorites({ (resultFav) in
      self.tableView.reloadData()
    })
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.sharedInstance.favoriteRadios.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
    cell.labelName.text = DataManager.sharedInstance.favoriteRadios[indexPath.row].name
    if let address = DataManager.sharedInstance.favoriteRadios[indexPath.row].address {
      cell.labelLocal.text = address.formattedLocal
    }
    cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.favoriteRadios[indexPath.row].thumbnail)))
    if DataManager.sharedInstance.favoriteRadios[indexPath.row].isFavorite {
      cell.imageSmallOne.image = UIImage(named: "heartRed.png")
    } else {
      cell.imageSmallOne.image = UIImage(named: "heart.png")
    }
    cell.labelDescriptionOne.text = "\(DataManager.sharedInstance.favoriteRadios[indexPath.row].likenumber)"
    cell.widthTextOne.constant = 30
    cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
    cell.labelDescriptionTwo.text = ""
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedRadio = DataManager.sharedInstance.favoriteRadios[indexPath.row]
    DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
  }
  
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    if DataManager.sharedInstance.favoriteRadios[indexPath.row].isFavorite {
      let favorite = UITableViewRowAction(style: .Normal, title: "Desfavoritar") { action, index in
        DataManager.sharedInstance.favoriteRadios[indexPath.row].updateIsFavorite(false)
        DataManager.sharedInstance.favoriteRadios[indexPath.row].removeOneLikesNumber()
        manager.deleteFavRadio(DataManager.sharedInstance.favoriteRadios[indexPath.row], completion: { (result) in
          manager.requestUserFavorites({ (resultFav) in
          })
        })
        DataManager.sharedInstance.favoriteRadios.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        if DataManager.sharedInstance.favoriteRadios.count == 0 {
          tableView.reloadData()
        }
      }
      favorite.backgroundColor = UIColor.orangeColor()
      return [favorite]
    } else {
      let favorite = UITableViewRowAction(style: .Normal, title: "Favoritar") { action, index in
        DataManager.sharedInstance.favoriteRadios[indexPath.row].updateIsFavorite(true)
        DataManager.sharedInstance.favoriteRadios[indexPath.row].addOneLikesNumber()
        manager.favRadio(DataManager.sharedInstance.favoriteRadios[indexPath.row], completion: { (result) in
          self.tableView.reloadData()
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
  //MARK: --- EMPTY TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem Favoritos"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Você não marcou nenhuma rádio como favorito, retorne a início e marque algumas!"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "happy.jpg")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    dismissViewControllerAnimated(true) { 
    }
  }
  
}
