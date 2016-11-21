//
//  GenreViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/10/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import Kingfisher

class GenreViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  var isSearchOn = false
  var searchResults = [GenreRealm]()
  var selectedGenre = GenreRealm()
  private let reuseIdentifier = "GenreCell"
  private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
  var buttonLateralMenu = UIBarButtonItem()
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    collectionView.backgroundView?.backgroundColor = UIColor.clearColor()
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    buttonLateralMenu.target = self.revealViewController()
    buttonLateralMenu.action = #selector(SWRevealViewController.revealToggle(_:))
    let tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.numberOfTapsRequired = 2
    tapRecognizer.addTarget(self, action: #selector(GenreViewController.collectionViewBackgroundTapped))
    self.collectionView.addGestureRecognizer(tapRecognizer)
    self.title = "Gêneros"
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    
    ///////////////////////////////////////////////////////////
    //MARK: --- REQUEST GENRE ---
    ///////////////////////////////////////////////////////////
    
    let manager = RequestManager()
    manager.requestMusicGenre { (resultGenre) in
      if resultGenre == true {
        self.collectionView.reloadData()
      }
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- COLECTIONVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if isSearchOn == true && !searchResults.isEmpty {
      return searchResults.count
    } else {
      return DataManager.sharedInstance.allMusicGenre.count
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GenreCell", forIndexPath: indexPath) as! GenreCollectionViewCell
      if isSearchOn == true && !searchResults.isEmpty {
        cell.labelText.text = searchResults[indexPath.item].name
      } else {
        cell.labelText.text = DataManager.sharedInstance.allMusicGenre[indexPath.item].name
      }
      cell.backgroundColor = UIColor.whiteColor()
      cell.imageGenre.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.allMusicGenre[indexPath.row].image)))
      cell.imageGenre.alpha = 0.8
      cell.labelText.textColor = UIColor.whiteColor()
      return cell
    
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    collectionView.allowsSelection = false
    if !isSearchOn {
      self.selectedGenre = DataManager.sharedInstance.allMusicGenre[indexPath.row]
    } else {
      self.selectedGenre = searchResults[indexPath.row]
    }
    let manager = RequestManager()
    manager.requestRadiosInGenre(selectedGenre.id,pageNumber:0,pageSize:20) { (resultGenre) in
      self.selectedGenre.updateRadiosOfGenre(resultGenre)
      self.collectionView.allowsSelection = true
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      for radio in resultGenre {
        radio.setRadioGenre(DataManager.sharedInstance.allMusicGenre[indexPath.row].name)
      }
      self.performSegueWithIdentifier("detailGenre", sender: self)
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- COLLECTIOVIEW LAYOUT DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake((collectionView.frame.size.width / 3)-4, (collectionView.frame.size.width / 3)-4)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(3, 3, 3, 3)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 3
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- SEARCH BAR DELEGATE ---
  ///////////////////////////////////////////////////////////
  
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
    for genre in DataManager.sharedInstance.allMusicGenre {
      let stringToLookFor = genre.name as NSString
      if stringToLookFor.localizedCaseInsensitiveContainsString(text as String) {
        searchResults.append(genre)
      }
    }
  }
  
  func collectionViewBackgroundTapped() {
    searchBar.resignFirstResponder()
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "detailGenre" {
      let radioVC = (segue.destinationViewController as! RadioListTableViewController)
      radioVC.radios = Array(selectedGenre.radios)
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
  
  @IBAction func searchbuttonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
}