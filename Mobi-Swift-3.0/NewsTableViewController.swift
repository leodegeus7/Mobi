//
//  NewsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController, UITextViewDelegate {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    menuButton.target = self.revealViewController()
    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
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
  
  override func viewWillAppear(animated: Bool) {

  }
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return DataManager.sharedInstance.allNews.count
  }
  
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if DataManager.sharedInstance.allNews[indexPath.row].type == "Complex" {
      let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
      cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
      cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
      cell.textDescription.text = DataManager.sharedInstance.allNews[indexPath.row].newDescription
      cell.imageDescription.backgroundColor = UIColor.redColor()
//      let heightTV = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
//      cell.heightView.constant = cell.labelDate.frame.height + cell.labelTitle.frame.height + heightTV + cell.imageDescription.frame.height
      return cell
    } else if DataManager.sharedInstance.allNews[indexPath.row].type == "Simple" {
      let cell = tableView.dequeueReusableCellWithIdentifier("secondCell", forIndexPath: indexPath) as! SecondNewTableViewCell
      cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
      cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
      cell.textDescription.text = DataManager.sharedInstance.allNews[indexPath.row].newDescription
      let heightTV = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
      cell.heightView.constant = cell.labelDate.frame.height + cell.labelTitle.frame.height + heightTV
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("thirdCell", forIndexPath: indexPath) as! ThirdNewTableViewCell
      cell.imageDescription.backgroundColor = UIColor.blueColor()
      cell.heightView.constant = cell.imageDescription.frame.height
      return cell
    }
    
    
  }
  
  
  
}
