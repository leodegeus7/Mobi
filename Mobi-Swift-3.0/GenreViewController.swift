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
  fileprivate let reuseIdentifier = "GenreCell"
  fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
  var buttonLateralMenu = UIBarButtonItem()
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  var notificationCenter = NotificationCenter.default
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    notificationCenter.addObserver(self, selector: #selector(GenreViewController.freezeView), name: NSNotification.Name(rawValue: "freezeViews"), object: nil)
    collectionView.backgroundView?.backgroundColor = UIColor.clear
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
    activityIndicator.isHidden = true
    
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
  
  func freezeView() {
    
    if DataManager.sharedInstance.menuIsOpen {
      self.collectionView.allowsSelection = false
      self.collectionView.isScrollEnabled = false
    } else {
      self.collectionView.allowsSelection = true
      self.collectionView.isScrollEnabled = true
    }
  }
  ///////////////////////////////////////////////////////////
  //MARK: --- COLECTIONVIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if isSearchOn == true && !searchResults.isEmpty {
      return searchResults.count
    } else {
      return DataManager.sharedInstance.allMusicGenre.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell", for: indexPath) as! GenreCollectionViewCell
      if isSearchOn == true && !searchResults.isEmpty {
        cell.labelText.text = searchResults[indexPath.item].name
      } else {
        cell.labelText.text = DataManager.sharedInstance.allMusicGenre[indexPath.item].name
      }
      cell.backgroundColor = UIColor.white
      cell.imageGenre.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(DataManager.sharedInstance.allMusicGenre[indexPath.row].image)))
      cell.imageGenre.alpha = 0.9
      cell.labelText.textColor = UIColor.white
      return cell
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    view.addSubview(activityIndicator)
    activityIndicator.isHidden = false
    collectionView.allowsSelection = false
    if !isSearchOn {
      self.selectedGenre = DataManager.sharedInstance.allMusicGenre[indexPath.row]
    } else {
      self.selectedGenre = searchResults[indexPath.row]
    }
    let manager = RequestManager()
    manager.requestRadiosInGenre(selectedGenre.id,pageNumber:0,pageSize:10) { (resultGenre) in
      self.selectedGenre.updateRadiosOfGenre(resultGenre)
      self.collectionView.allowsSelection = true
      self.activityIndicator.isHidden = true
      self.activityIndicator.removeFromSuperview()
      for radio in resultGenre {
        radio.setRadioGenre(DataManager.sharedInstance.allMusicGenre[indexPath.row].name)
      }
      self.performSegue(withIdentifier: "detailGenre", sender: self)
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- COLLECTIOVIEW LAYOUT DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.frame.size.width / 3)-4, height: (collectionView.frame.size.width / 3)-4)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(3, 3, 3, 3)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 3
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- SEARCH BAR DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar!) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    isSearchOn = false
    self.collectionView.reloadData()
  }
  
  func searchBar(_ searchBar: UISearchBar!, textDidChange searchText: String!) {
    searchBar.showsCancelButton = true
    if !searchText.isEmpty {
      isSearchOn = true
      self.filterContentForSearchText(searchText)
      self.collectionView.reloadData()
    }
  }
  
  func filterContentForSearchText(_ text: String) {
    searchResults.removeAll(keepingCapacity: false)
    for genre in DataManager.sharedInstance.allMusicGenre {
      let stringToLookFor = genre.name as NSString
      if stringToLookFor.localizedCaseInsensitiveContains(text as String) {
        searchResults.append(genre)
      }
    }
  }
  
  func collectionViewBackgroundTapped() {
    searchBar.resignFirstResponder()
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "detailGenre" {
      let radioVC = (segue.destination as! RadioListTableViewController)
      radioVC.radios = Array(selectedGenre.radios)
      radioVC.superSegue = "detailGenre"
      radioVC.idGenreSelected = selectedGenre.id
    }
  }
  
  @IBAction func menuTap(_ sender: AnyObject) {
    searchBar.resignFirstResponder()
    view.endEditing(true)
    UIApplication.shared.sendAction(buttonLateralMenu.action!, to: buttonLateralMenu.target, from: self, for: nil)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  @IBAction func searchbuttonTap(_ sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
}
