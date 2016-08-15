//
//  NewsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController, UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return DataManager.sharedInstance.news.count
    }


  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//      
      if (indexPath.row == 0) {
        let cell = tableView.dequeueReusableCellWithIdentifier("secondCell", forIndexPath: indexPath) as! SecondNewTableViewCell
        cell.labelDate.text = DataManager.sharedInstance.news[indexPath.row].date
        cell.labelTitle.text = DataManager.sharedInstance.news[indexPath.row].title
        cell.textDescription.text = DataManager.sharedInstance.news[indexPath.row].newDescription
        return cell
      } else if (indexPath.row == 1) {
        let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
        cell.labelDate.text = DataManager.sharedInstance.news[indexPath.row].date
        cell.labelTitle.text = DataManager.sharedInstance.news[indexPath.row].title
        cell.textDescription.text = DataManager.sharedInstance.news[indexPath.row].newDescription
        cell.imageDescription.backgroundColor = UIColor.redColor()
        return cell
      }
        let cell = tableView.dequeueReusableCellWithIdentifier("thirdCell", forIndexPath: indexPath) as! ThirdNewTableViewCell
        cell.imageDescription.backgroundColor = UIColor.blueColor()
      return cell
  }



}
