//
//  NewsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit

class NewsTableViewController: UITableViewController, UITextViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    menuButton.target = self.revealViewController()
    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    self.title = "Notícias"
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.sharedInstance.allNews.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if DataManager.sharedInstance.allNews[indexPath.row].type == "Complex" {
      let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
      cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
      cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
      cell.textDescription.text = DataManager.sharedInstance.allNews[indexPath.row].newDescription
      cell.imageDescription.image = UIImage(named: DataManager.sharedInstance.allNews[indexPath.row].img)
      
      cell.heightTextView.constant = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
      return cell
    } else if DataManager.sharedInstance.allNews[indexPath.row].type == "Simple" {
      let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
      cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
      cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
      cell.textDescription.text = DataManager.sharedInstance.allNews[indexPath.row].newDescription
      let heightTV = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
      cell.heightTextView.constant = heightTV
      cell.imageDescription.frame = CGRectMake(0, 0, 0, 0)
      cell.imageDescription.viewWithTag(0)?.removeFromSuperview()
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("thirdCell", forIndexPath: indexPath) as! ThirdNewTableViewCell
      cell.imageDescription.image = UIImage(named: DataManager.sharedInstance.allNews[indexPath.row].img)
      cell.heightView.constant = cell.imageDescription.frame.height
      return cell
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTY TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem Notícias"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Nenhuma notícia para mostrar"
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
