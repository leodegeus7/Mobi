//
//  GenreViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class GenreViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchBar: UISearchBar!
  var isSearchOn = false
  var searchResults = [Genre]()
  var selectedGenre = Genre()
  var allGenre = [Genre]()
  private let reuseIdentifier = "GenreCell"
  var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
  private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  var buttonLateralMenu = UIBarButtonItem()
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    separateInformation()
    collectionView.backgroundView?.backgroundColor = UIColor.clearColor()
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    
    buttonLateralMenu.target = self.revealViewController()
    buttonLateralMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    
    let tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.numberOfTapsRequired = 2
    
    tapRecognizer.addTarget(self, action: #selector(GenreViewController.collectionViewBackgroundTapped))
    
    self.collectionView.addGestureRecognizer(tapRecognizer)
    
    self.title = "Gêneros"
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: --- CollectionView Delegate ---
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if isSearchOn == true && !searchResults.isEmpty {
      return searchResults.count
    } else {
      return allGenre.count
    }
    
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GenreCell", forIndexPath: indexPath) as! GenreCollectionViewCell
    
    if isSearchOn == true && !searchResults.isEmpty {
      cell.labelText.text = searchResults[indexPath.item].genreName
    } else {
      cell.labelText.text = self.allGenre[indexPath.item].genreName
    }
    
    
    cell.backgroundColor = UIColor.whiteColor()
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if !isSearchOn {
      self.selectedGenre = allGenre[indexPath.row]
    } else {
      self.selectedGenre = searchResults[indexPath.row]
    }
    performSegueWithIdentifier("detailGenre", sender: self)
  }
  
  //MARK: --- CollectionView Layout Delegate ---
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake((collectionView.frame.size.width / 3)-4, (collectionView.frame.size.width / 3)-4)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(3, 3, 3, 3)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 3
  }
  
  //MARK: --- SearchBar Delegate ---
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar!) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    isSearchOn = false
    self.collectionView.reloadData()
  }
  
  func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
    searchBar.showsCancelButton = true
    if !searchText.isEmpty {
      isSearchOn = true
      self.filterContentForSearchText(searchText)
      self.collectionView.reloadData()
    }
  }
  
  func filterContentForSearchText(text: String) {
    searchResults.removeAll(keepCapacity: false)
    for genre in allGenre {
      
      let stringToLookFor = genre.genreName as NSString
      
      if stringToLookFor.localizedCaseInsensitiveContainsString(text as String) {
        searchResults.append(genre)
      }
    }
  }
  
  func collectionViewBackgroundTapped() { //dissmiss keyboard
    searchBar.resignFirstResponder()
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true //possibilita funcionar o tap do background com o tap na célula
  }
  
  
  func separateInformation() {
    if DataManager.sharedInstance.allRadios.count == 0 {

        return
    }
    if DataManager.sharedInstance.allRadios[0].genre == nil {
        return
    }
    var genres = [String]()
    
    for radio in DataManager.sharedInstance.allRadios {
      if radio.genre != "" {
        genres.append(radio.genre)
      }
    }
    
    genres = Util.removeDuplicateStrings(genres)
    
    for genre in genres {
      var radios = [RadioRealm]()
      for radio in DataManager.sharedInstance.allRadios {
        if (genre == radio.genre) {
          radios.append(radio)
          break
        }
      }
      allGenre.append(Genre(genreName: genre, radios: radios))
    }
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailGenre" {
      let radioVC = (segue.destinationViewController as! RadioListTableViewController)
      radioVC.radios = selectedGenre.radios
      radioVC.superSegue = "detailGenre"
    }
  }
  
  @IBAction func menuTap(sender: AnyObject) {
    searchBar.resignFirstResponder()
    view.endEditing(true)
    UIApplication.sharedApplication().sendAction(buttonLateralMenu.action, to: buttonLateralMenu.target, from: self, forEvent: nil)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  override func viewDidDisappear(animated: Bool) {

  }
  
  @IBAction func searchbuttonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }

  
}


