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
  var idCitySelected = ""
  var idGenreSelected = ""
  var pagesLoaded = 1
  var inProcess = false
  
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
    tableView.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
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
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return radios.count + 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == (10*pagesLoaded - 1) && !inProcess {
      inProcess = true
      
      self.pushMoreRadios()
    } else if indexPath.row == (10*pagesLoaded - 1) && superSegue == "detailGenre" && !inProcess {
      inProcess = true
      
      self.pushMoreRadios()
    }
    if indexPath.row <= radios.count-1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
      cell.labelName.text = radios[indexPath.row].name
      cell.labelLocal.text = radios[indexPath.row].address.formattedLocal
      cell.imageBig.kf_indicatorType = .activity
      cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(radios[indexPath.row].thumbnail)))
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
      cell.selectionStyle = .none
      return cell
    }

  }
  
  func pushMoreRadios() {
    if superSegue == "detailCity" {
    let manager = RequestManager()
    manager.requestRadiosInCity(idCitySelected,pageNumber:pagesLoaded+1,pageSize:10, completion: { (resultCity) in
      self.pagesLoaded += 1
      self.inProcess = false
      self.radios.append(contentsOf: resultCity)
      self.tableView.reloadData()
    })
    }
    if superSegue == "detailGenre" {
    let manager = RequestManager()
    manager.requestRadiosInGenre(idGenreSelected,pageNumber:pagesLoaded+1,pageSize:10) { (resultGenre) in
      self.pagesLoaded += 1
      self.inProcess = false
      self.radios.append(contentsOf: resultGenre)
      self.tableView.reloadData()
    }
    }
  }

  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= radios.count-1 {
    selectedRadio = radios[indexPath.row]
          performSegue(withIdentifier: "detailRadio2", sender: self)
    }
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let manager = RequestManager()
    if radios[indexPath.row].isFavorite {
      let favorite = UITableViewRowAction(style: .normal, title: "Desfavoritar") { action, index in
        self.radios[indexPath.row].updateIsFavorite(false)
        self.radios[indexPath.row].removeOneLikesNumber()
        manager.deleteFavRadio(self.radios[indexPath.row], completion: { (result) in
          manager.requestUserFavorites({ (resultFav) in
          })
        })
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
      }
      favorite.backgroundColor = UIColor.orange
      return [favorite]
    } else {
      let favorite = UITableViewRowAction(style: .normal, title: "Favoritar") { action, index in
        if DataManager.sharedInstance.isLogged {
          self.radios[indexPath.row].updateIsFavorite(true)
          self.radios[indexPath.row].addOneLikesNumber()
          manager.favRadio(self.radios[indexPath.row], completion: { (result) in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
          })
        } else {
          func okAction() {
            DataManager.sharedInstance.instantiateProfile(self.navigationController!)
          }
          func cancelAction() {
          }
          self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário efetuar login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
        }
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
  //MARK: --- OTHER FUNCTIONS ---
  ///////////////////////////////////////////////////////////
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "detailRadio2" {
      let radioVC = (segue.destination as! RadioTableViewController)
      radioVC.actualRadio = selectedRadio
    }
    let backButton = UIBarButtonItem()
    backButton.title = "Voltar"
    navigationItem.backBarButtonItem = backButton
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem registros"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if superSegue == "detailGenre" {
      str = "Não foi possivel localizar nenhuma rádio com este gênero"
    } else if superSegue == "detailCity" {
      str = "Não foi possível localizar nenhuma rádio com este local"
    }
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
