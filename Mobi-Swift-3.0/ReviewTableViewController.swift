//
//  ReviewTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import Kingfisher

class ReviewTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  ///////////////////////////////////////////////////////////
  //MARK: --- VARIABLE SET ---
  ///////////////////////////////////////////////////////////
  
  var actualRadio = RadioRealm()
  var actualReviews = [Review]()
  var firstTimeShowed = true
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- VARIABLE SET ---
    ///////////////////////////////////////////////////////////
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    view.addSubview(activityIndicator)
    activityIndicator.isHidden = false
    tableView.allowsSelection = false
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    self.clearsSelectionOnViewWillAppear = true
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    let scoreRequest = RequestManager()
    self.title = "Avaliações"
    let rigthButton = UIBarButtonItem(title: "Avaliar", style: .done, target: self, action: #selector(ReviewTableViewController.segueToCreatePublication))
    navigationItem.rightBarButtonItem = rigthButton
    
    ///////////////////////////////////////////////////////////
    //MARK: --- INITIAL REQUEST ---
    ///////////////////////////////////////////////////////////
    
    scoreRequest.requestReviewsInRadio(actualRadio, pageSize: 50, pageNumber: 0) { (resultScore) in
      self.tableView.allowsSelection = true
      self.activityIndicator.isHidden = true
      self.activityIndicator.removeFromSuperview()
      self.actualReviews = resultScore
      self.firstTimeShowed = false
      self.tableView.reloadData()
    }
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
    // #warning Incomplete implementation, return the number of rows
    if firstTimeShowed {
      return 1
    } else {
      return actualReviews.count + 1
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if !firstTimeShowed {
      if indexPath.row <= actualReviews.count-1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        cell.labelName.text = actualReviews[indexPath.row].user.name
        cell.labelDate.text = Util.getOverdueInterval(actualReviews[indexPath.row].date)
        cell.textViewReview.text = actualReviews[indexPath.row].text
        if actualReviews[indexPath.row].user.userImage == "avatar.png" {
          cell.imageUser.image = UIImage(named: "avatar.png")
        } else {
          cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualReviews[indexPath.row].user.userImage)))
        }
        if actualReviews[indexPath.row].score != 0 && actualReviews[indexPath.row].score != -1 {
          for index in 0...actualReviews[indexPath.row].score-1 {
            cell.stars[index].image = UIImage(named: "star.png")
            cell.stars[index].tintColor = UIColor.red
          }
        }
        cell.selectionStyle = .none
        return cell
      } else {
        let cell = UITableViewCell()
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        cell.selectionStyle = .none
        return cell
      }
    } else {
      let cell = UITableViewCell()
      return cell
    }
  }
  
  func segueToCreatePublication() {
    if DataManager.sharedInstance.isLogged {
      performSegue(withIdentifier: "createPublicacionSegue", sender: self)
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário efetuar login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "createPublicacionSegue" {
      let createVC = (segue.destination as! SendPublicationViewController)
      createVC.actualMode = .review
      createVC.actualRadio = actualRadio
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Nenhum review realizado ainda"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Clique aqui e seja o primeiro a realizar uma avaliação de  \(actualRadio.name)"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
    performSegue(withIdentifier: "createPublicacionSegue", sender: self)
  }
  
  
}
