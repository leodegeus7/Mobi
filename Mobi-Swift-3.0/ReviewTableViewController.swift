//
//  ReviewTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/11/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class ReviewTableViewController: UITableViewController {


    var actualRadio = RadioRealm()
    var actualReviews = [Review]()
  
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
    override func viewDidLoad() {
        super.viewDidLoad()

      activityIndicator.center = view.center
      activityIndicator.startAnimating()
      activityIndicator.hidden = true
      
      tableView.estimatedRowHeight = 40
      tableView.rowHeight = UITableViewAutomaticDimension
      
      let scoreRequest = RequestManager()
      
      scoreRequest.requestReviewsInRadio(actualRadio, pageSize: 50, pageNumber: 0) { (resultScore) in
        self.actualReviews = resultScore
        self.tableView.reloadData()
      }
      
      self.clearsSelectionOnViewWillAppear = true
    
      
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
        return actualReviews.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
