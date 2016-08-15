//
//  LocalTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class LocalTableViewController: UITableViewController,UISearchBarDelegate {
    var isSearchOn = false
    var searchResults = [String]()
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
  @IBOutlet weak var searchBar: UISearchBar!
  
    override func viewDidLoad() {
        super.viewDidLoad()

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
        if isSearchOn == true && !searchResults.isEmpty {
          return searchResults.count
        } else {
          return items.count
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("localCell", forIndexPath: indexPath) as! LocalTableViewCell
        if isSearchOn == true && !searchResults.isEmpty {
          cell.labelLocal.text = searchResults[indexPath.item]
        } else {
          cell.labelLocal.text = items[indexPath.row]
        }
      

        return cell
    }
  
  //MARK: --- SearchBar Delegate ---
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.showsCancelButton = false
    searchBar.resignFirstResponder()
    isSearchOn = false
    self.tableView.reloadData()
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    searchBar.showsCancelButton = true
    if !searchText.isEmpty {
      isSearchOn = true
      self.filterContentForSearchText(searchText)
      self.tableView.reloadData()
    }
  }
  
  func filterContentForSearchText(text: String) {
    searchResults.removeAll(keepCapacity: false)
    for item in items {
      let stringToLookFor = item as NSString
      
      if stringToLookFor.localizedCaseInsensitiveContainsString(text as String) {
        searchResults.append(item)
      }
    }
  }
  
  func collectionViewBackgroundTapped() { //dissmiss keyboard
    searchBar.resignFirstResponder()
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true //possibilita funcionar o tap do background com o tap na célula
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
