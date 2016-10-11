//
//  ReviewTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class ReviewTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  
  var actualRadio = RadioRealm()
  var actualReviews = [Review]()
  var firstTimeShowed = true
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    tableView.allowsSelection = false
    
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    
    let scoreRequest = RequestManager()
    self.title = "Avaliações"
    
    
    scoreRequest.requestReviewsInRadio(actualRadio, pageSize: 50, pageNumber: 0) { (resultScore) in
      self.tableView.allowsSelection = true
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      self.actualReviews = resultScore
      self.firstTimeShowed = false
      self.tableView.reloadData()
    }
    
    self.clearsSelectionOnViewWillAppear = true
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if firstTimeShowed {
      return 1
    } else {
      return actualReviews.count
    }
    
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if !firstTimeShowed {
      let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
      cell.labelName.text = actualReviews[indexPath.row].user.name
      
      cell.labelDate.text = Util.getOverdueInterval(actualReviews[indexPath.row].date)
      cell.textViewReview.text = actualReviews[indexPath.row].text
      if actualReviews[indexPath.row].user.userImage == "avatar.png" {
        cell.imageUser.image = UIImage(named: "avatar.png")
      } else {
        cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualReviews[indexPath.row].user.userImage)))
      }
      
      
      if actualReviews[indexPath.row].score != 0 && actualReviews[indexPath.row].score != -1 {
        for index in 0...actualReviews[indexPath.row].score-1 {
          cell.stars[index].image = UIImage(named: "star.png")
          cell.stars[index].tintColor = UIColor.redColor()
        }
      }
      
      return cell
    } else {
      let cell = UITableViewCell()

      return cell
    }
  }
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Nenhum review realizado ainda"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Clique aqui e seja o primeiro a realizar uma avaliação de  \(actualRadio.name)"
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
