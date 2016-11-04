//
//  CommentsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/3/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  var actualRadio:RadioRealm!
  var actualComment :Comment!
  var actualSubComments : [Comment]!
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  var firstTimeToShow = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Comentários"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "plus.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.createComment))
    let requestManager = RequestManager()
    requestManager.requestComments(actualComment, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
      self.actualSubComments = resultWall
      self.tableView.allowsSelection = true
      self.activityIndicator.hidden = true
      self.self.activityIndicator.removeFromSuperview()
      self.tableView.reloadData()
    })
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    self.clearsSelectionOnViewWillAppear = true
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func viewWillAppear(animated: Bool) {
    firstTimeToShow = true
    self.tableView.reloadData()
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    tableView.allowsSelection = false
    self.clearsSelectionOnViewWillAppear = true
    let requestManager = RequestManager()
    requestManager.requestComments(actualComment, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
      self.actualSubComments = resultWall
      self.tableView.allowsSelection = true
      self.activityIndicator.hidden = true
      self.self.activityIndicator.removeFromSuperview()
      self.tableView.reloadData()
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  func createComment() {
    if DataManager.sharedInstance.isLogged {
      performSegueWithIdentifier("createPublicacionSegue", sender: self)
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário efetuar login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "createPublicationSegue" {
      let createVC = (segue.destinationViewController as! SendPublicationViewController)
      createVC.actualMode = .Comment
      createVC.actualComment = actualComment
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if firstTimeToShow {
      return 1
    } else {
      return actualSubComments.count
    }
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if firstTimeToShow {
      let cell = UITableViewCell()
      firstTimeToShow = false
      return cell
    }
    else {
      let cell = tableView.dequeueReusableCellWithIdentifier("wallCell", forIndexPath: indexPath) as! WallTableViewCell
      cell.labelName.text = actualSubComments[indexPath.row].user.name
      cell.labelDate.text = Util.getOverdueInterval(actualSubComments[indexPath.row].date)
      cell.textViewWall.text = actualSubComments[indexPath.row].text
      if actualSubComments[indexPath.row].user.userImage == "avatar.png" {
        cell.imageUser.image = UIImage(named: "avatar.png")
      } else {
        cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualSubComments[indexPath.row].user.userImage)))
      }
      return cell
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    
    let str = "Nenhuma comentario na publicação"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    str = "Clique aqui para comentar no comentário"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    performSegueWithIdentifier("createPublicationSegue", sender: self)
  }
  
}
