//
//  SearchTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 9/12/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController,UISearchBarDelegate,UISearchResultsUpdating,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  var selectedMode:SearchMode = .All
  var searchWord:String!
  var searchStates = [StateRealm]()
  var searchCities = [CityRealm]()
  var searchGenre = [GenreRealm]()
  var searchRadios = [RadioRealm]()
  var searchAll = Dictionary<SearchMode,[AnyObject]>()
  
  var isOneTimeSearched = false
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  var selectedRadio = RadioRealm()
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 120
    searchAll[.Radios] = [RadioRealm]()
    searchAll[.Genre] = [GenreRealm]()
    searchAll[.Cities] = [CityRealm]()
    searchAll[.States] = [StateRealm]()
    self.title = "Pesquisar"
    tableView.registerNib(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    
    let colorWhite =  ColorRealm(name: 45, red: components[0]+0.4, green: components[1]+0.4, blue: components[2]+0.4, alpha: 1).color
    
    searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: .Normal)
    searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName:colorWhite], forState: .Selected)
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    switch selectedMode {
    case .All:
      return 4
    case .Local:
      return 2
    default:
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .All:
      switch section {
      case 0:
        if searchRadios.count <= 3 {
          return searchRadios.count+1
        } else {
          return 4+1
        }
      case 1:
        if searchGenre.count <= 3 {
          return searchGenre.count
        } else {
          return 4
        }
      case 2:
        if searchStates.count <= 3 {
          return searchStates.count
        } else {
          return 4
        }
      case 3:
        if searchCities.count <= 3 {
          return searchCities.count
        } else {
          return 4
        }
      default:
        return 0
      }
    case .Radios:
      return searchRadios.count
    case .Genre:
      return searchGenre.count
    case .Local:
      switch section {
      case 0:
        return searchStates.count
      case 1:
        return searchCities.count
      default:
        return 0
      }
    default:
      return 0
    }
    
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch selectedMode {
    case .All:
      switch indexPath.section {
      case 0:
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("adsCell", forIndexPath: indexPath) as! AdsTableViewCell
          let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
          let colorWhite =  ColorRealm(name: 45, red: components[0]+0.2, green: components[1]+0.2, blue: components[2]+0.2, alpha: 1).color
          cell.adsButton.backgroundColor = colorWhite
          cell.adsButton.setBackgroundImage(UIImage(named: "anuncio2.png"), forState: .Normal)
          cell.selectionStyle = .None
          AdsManager.sharedInstance.setAdvertisement(.PlayerScreen, completion: { (resultAd) in
            dispatch_async(dispatch_get_main_queue()) {
              if let imageAd = resultAd.image {
                let imageView = UIImageView(frame: cell.adsButton.frame)
                imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
                cell.adsButton.setBackgroundImage(imageView.image, forState: .Normal)
              }
            }
          })
          return cell
        }
        if indexPath.row < 4 {
          let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
          cell.labelName.text = searchRadios[indexPath.row-1].name
          if let address = searchRadios[indexPath.row-1].address {
            cell.labelLocal.text = address.formattedLocal
          }
          cell.imageBig.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(searchRadios[indexPath.row-1].thumbnail)))
          cell.imageSmallOne.image = UIImage(named: "heart.png")
          cell.labelDescriptionOne.text = "\(searchRadios[indexPath.row-1].likenumber)"
          cell.widthTextOne.constant = 30
          cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
          cell.labelDescriptionTwo.text = ""
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("readMoreCell", forIndexPath: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 1:
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchGenre[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("readMoreCell", forIndexPath: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 2:
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchStates[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("readMoreCell", forIndexPath: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 3:
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchCities[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("readMoreCell", forIndexPath: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      default:
        break
      }
    case .Local:
      switch indexPath.section {
      case 0:
        let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
        cell.labelTitle.text = searchStates[indexPath.row].name
        return cell
      case 1:
        let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
        cell.labelTitle.text = searchCities[indexPath.row].name
        return cell
      default:
        let cell = UITableViewCell()
        return cell
      }
    case .Genre:
      let cell = tableView.dequeueReusableCellWithIdentifier("flagCell", forIndexPath: indexPath) as! SimpleFlagTableViewCell
      cell.labelTitle.text = searchGenre[indexPath.row].name
      return cell
    case .Radios:
      let cell = tableView.dequeueReusableCellWithIdentifier("baseCell", forIndexPath: indexPath) as! InitialTableViewCell
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
    let cell = UITableViewCell()
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
      let genres =  self.searchAll[.Genre]
      let cities =  self.searchAll[.Cities]
      let states =  self.searchAll[.States]
      self.searchRadios = radios as! [RadioRealm]
      self.searchGenre = genres as! [GenreRealm]
      self.searchCities = cities as! [CityRealm]
      self.searchStates = states as! [StateRealm]
      
      self.tableView.reloadData()
    }
    isOneTimeSearched = true
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
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    self.tableView.allowsSelection = false
    switch selectedMode {
    case .All:
      switch indexPath.section {
      case 0:
        if indexPath.row == 0 {
          
        }
        else if indexPath.row == 4 {
          selectedMode = .Radios
          searchBar.selectedScopeButtonIndex = 1
          tableView.reloadData()
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
        }

        else if indexPath.row >= 1 && indexPath.row <= 3 {
          selectedRadio = searchRadios[indexPath.row-1]
          DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
        }
      case 1:
        if indexPath.row == 3 {
          selectedMode = .Genre
          searchBar.selectedScopeButtonIndex = 2
          tableView.reloadData()
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
        } else {
          let genre = searchGenre[indexPath.row]
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          let manager = RequestManager()
          manager.requestRadiosInGenre(genre.id,pageNumber: 0,pageSize: 20) { (resultGenre) in
            genre.updateRadiosOfGenre(resultGenre)
            self.tableView.allowsSelection = true
            self.activityIndicator.hidden = true
            self.activityIndicator.removeFromSuperview()
            for radio in resultGenre {
              radio.setRadioGenre(DataManager.sharedInstance.allMusicGenre[indexPath.row].name)
            }
            DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: resultGenre,title:genre.name)
          }
        }
      case 2:
        if indexPath.row == 3 {
          selectedMode = .Local
          searchBar.selectedScopeButtonIndex = 3
          tableView.reloadData()
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
        } else {
          let state = searchStates[indexPath.row]
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
          DataManager.sharedInstance.instantiateCitiesInStateView(navigationController!, state: state)
        }
      case 3:
        if indexPath.row == 3 {
          selectedMode = .Local
          searchBar.selectedScopeButtonIndex = 3
          tableView.reloadData()
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
        } else {
          
          let city = searchCities[indexPath.row]
          let manager = RequestManager()
          manager.requestRadiosInCity(city.id, completion: { (resultCity) in
            city.updateRadiosOfCity(resultCity)
            self.tableView.allowsSelection = true
            self.activityIndicator.hidden = true
            self.activityIndicator.removeFromSuperview()
            DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: Array(city.radios),title:city.name)
          })
          

        }
      default:
        break
      }
    case .Radios:
      selectedRadio = searchRadios[indexPath.row]
      DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      self.tableView.allowsSelection = true
    case .Local:
      switch indexPath.section {
      case 0:
        let state = searchStates[indexPath.row]
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        self.tableView.allowsSelection = true
        DataManager.sharedInstance.instantiateCitiesInStateView(navigationController!, state: state)
      case 1:
        let city = searchCities[indexPath.row]
        let manager = RequestManager()
        manager.requestRadiosInCity(city.id, completion: { (resultCity) in
          city.updateRadiosOfCity(resultCity)
          self.tableView.allowsSelection = true
          self.activityIndicator.hidden = true
          self.activityIndicator.removeFromSuperview()
          DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: Array(city.radios),title:city.name)
        })
      default:
        break
      }
    case .Genre:
      let genre = searchGenre[indexPath.row]
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      let manager = RequestManager()
      manager.requestRadiosInGenre(genre.id,pageNumber: 0,pageSize: 20) { (resultGenre) in
        genre.updateRadiosOfGenre(resultGenre)
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        for radio in resultGenre {
          radio.setRadioGenre(DataManager.sharedInstance.allMusicGenre[indexPath.row].name)
        }
        DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: resultGenre,title:genre.name)
      }
    default:
      self.activityIndicator.hidden = true
      self.activityIndicator.removeFromSuperview()
      break
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch selectedMode {
    case .Local:
      if searchCities.count + searchStates.count > 0 {
        switch section {
        case 0:
          return "Estados"
        case 1:
          return "Cidades"
        default:
          return ""
        }
      }
    case .All:
      if searchRadios.count + searchCities.count + searchStates.count + searchGenre.count + searchCities.count > 0 {
        switch section {
        case 0:
          return "Radios"
        case 1:
          return "Gêneros"
        case 2:
          return "Estados"
        case 3:
          return "Cidades"
        default:
          return ""
        }
      } else {
        return ""
      }
    default:
      return ""
    }
    return ""
  }
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if !isOneTimeSearched {
      str = "Realize uma pesquisa a cima"
      let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
      return NSAttributedString(string: str, attributes: attr)
    } else {
      
      if selectedMode == .All {
        str = "Nenhum resultado encontrado"
      } else if selectedMode == .Genre {
        str = "Nenhum gênero foi encontrado"
      } else if selectedMode == .Local {
        str = "Nenhum local foi encontrado"
      } else if selectedMode == .Radios {
        str = "Nenhuma rádio foi reproduzida"
      } else {
        str = "Nenhuma radio para mostrar"
      }
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if !isOneTimeSearched {
      str = "Para algum conteúdo aparecer nesta pesquisa, digite seu texto no barra a cima"
      let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
      return NSAttributedString(string: str, attributes: attr)
    } else {
      
      if selectedMode == .All {
        str = "Nenhum resultado encontrado para o termo pesquisado"
      } else if selectedMode == .Genre {
        str = "Nenhum gênero foi encontrado com o texto digitado, tente digitar outro termo"
      } else if selectedMode == .Local {
        str = "Nenhum local foi encontrado com o texto digitado, tente digitar outro termo"
      } else if selectedMode == .Radios {
        str = "Nenhuma râdio foi encontrada com o texto digitado, tente digitar outro termo"
      } else {
        str = ""
      }
    }
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "happy.jpg")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
}
