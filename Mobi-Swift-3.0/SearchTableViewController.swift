//
//  SearchTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/12/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController,UISearchBarDelegate,UISearchResultsUpdating {
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var selectedMode:searchMode = .All
  var searchWord:String!
  var searchLocal = [String]()
  var searchGenre = [String]()
  var searchRadios = [RadioRealm]()
  var searchAll = Dictionary<searchMode,[AnyObject]>()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 120
    searchAll[.Radios] = [RadioRealm]()
    searchAll[.Genre] = [String]()
    searchAll[.Local] = [String]()
    self.title = "Pesquisar"
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    switch selectedMode {
    case .All:
      return 3
    default:
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .All:
      return 0
    case .Radios:
      return searchRadios.count
    case .Genre:
      return searchGenre.count
    case .Local:
      return searchLocal.count
    }
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch selectedMode {
    case .Radios:
        let cell = tableView.dequeueReusableCellWithIdentifier("radioCell", forIndexPath: indexPath) as! InitialTableViewCell
        cell.labelName.text = searchRadios[indexPath.row].name
        if let address = searchRadios[indexPath.row].address {
          cell.labelLocal.text = address.formattedLocal
        }
        cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(searchRadios[indexPath.row].thumbnail)))
        cell.imageSmallOne.image = UIImage(named: "heart.png")
        cell.labelDescriptionOne.text = "\(searchRadios[indexPath.row].likenumber)"
        cell.widthTextOne.constant = 30
        cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
        cell.labelDescriptionTwo.text = ""
        return cell
    default:
      break
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("radioCell", forIndexPath: indexPath) as! InitialTableViewCell
    // Configure the cell...
    
    return cell
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {

    
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    print(searchController.searchBar.text)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    print(searchBar.text!)
    searchBar.resignFirstResponder()
    view.endEditing(true)
    let manager = RequestManager()
    manager.searchWithWord(searchBar.text!) { (searchRequestResult) in
      print(searchRequestResult)
      self.searchAll = searchRequestResult
      let radios =  self.searchAll[.Radios]
      self.searchRadios = radios as! [RadioRealm]
      self.tableView.reloadData()
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    self.tableView.reloadData()
  }
  
  func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    switch selectedScope {
    case 0:
      selectedMode = .All
      break
    case 1:
      selectedMode = .Radios
      break
    case 2:
      selectedMode = .Genre
      break
    case 3:
      selectedMode = .Local
      break
    default:
      break
    }
    tableView.reloadData()
  }
  
}
