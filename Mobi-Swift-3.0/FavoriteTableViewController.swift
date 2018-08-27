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
    tableView.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func viewWillAppear(_ animated: Bool) {
    
    let manager = RequestManager()
    manager.requestUserFavorites({ (resultFav) in
      self.tableView.reloadData()
    })
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if DataManager.sharedInstance.favoriteRadios.count > 0 {
      return DataManager.sharedInstance.favoriteRadios.count + 1
    } else {
      return 0
    }

  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row <= DataManager.sharedInstance.favoriteRadios.count-1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
      cell.labelName.text = DataManager.sharedInstance.favoriteRadios[indexPath.row].name
      if let address = DataManager.sharedInstance.favoriteRadios[indexPath.row].address {
        cell.labelLocal.text = address.formattedLocal
      }
      cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.favoriteRadios[indexPath.row].thumbnail)))
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
    } else {
      let cell = UITableViewCell()
      cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedRadio = DataManager.sharedInstance.favoriteRadios[indexPath.row]
    DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    if DataManager.sharedInstance.favoriteRadios[indexPath.row].isFavorite {
      let favorite = UITableViewRowAction(style: .normal, title: "Desfavoritar") { action, index in
        DataManager.sharedInstance.favoriteRadios[indexPath.row].updateIsFavorite(false)
        DataManager.sharedInstance.favoriteRadios[indexPath.row].removeOneLikesNumber()
        manager.deleteFavRadio(DataManager.sharedInstance.favoriteRadios[indexPath.row], completion: { (result) in
          manager.requestUserFavorites({ (resultFav) in
          })
        })
        DataManager.sharedInstance.favoriteRadios.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if DataManager.sharedInstance.favoriteRadios.count == 0 {
          tableView.reloadData()
        }
      }
      favorite.backgroundColor = UIColor.orange
      return [favorite]
    } else {
      let favorite = UITableViewRowAction(style: .normal, title: "Favoritar") { action, index in
        DataManager.sharedInstance.favoriteRadios[indexPath.row].updateIsFavorite(true)
        DataManager.sharedInstance.favoriteRadios[indexPath.row].addOneLikesNumber()
        manager.favRadio(DataManager.sharedInstance.favoriteRadios[indexPath.row], completion: { (result) in
          self.tableView.reloadData()
        })
        
        
      }
      
      favorite.backgroundColor = UIColor.orange
      return [favorite]
    }
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTY TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem Favoritos"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Você não marcou nenhuma rádio como favorito, retorne a início e marque algumas!"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "logo-pretaAbert.png")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
    dismiss(animated: true) {
    }
  }
  
}
