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
  
  var selectedMode:SearchMode = .all
  var searchWord:String!
  var searchStates = [StateRealm]()
  var searchCities = [CityRealm]()
  var searchGenre = [GenreRealm]()
  var searchRadios = [RadioRealm]()
  var searchUsers = [UserRealm]()
  var searchAll = Dictionary<SearchMode,[AnyObject]>()
  
  var isOneTimeSearched = false
  
  
  var radiosIsExpanted = false
  var statesIsExpanted = false
  var citiesIsExpanted = false
  var genreIsExpanted = false
  var usersIsExpanted = false
  
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  var selectedRadio = RadioRealm()
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.rowHeight = 120
    searchAll[.radios] = [RadioRealm]()
    searchAll[.genre] = [GenreRealm]()
    searchAll[.cities] = [CityRealm]()
    searchAll[.states] = [StateRealm]()
    searchAll[.users] = [UserRealm]()
    self.title = "Pesquisar"
    tableView.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    
    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    
    let colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.4, green: (components?[1])!+0.4, blue: (components?[2])!+0.4, alpha: 1).color
    
    searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white], for: UIControlState())
    searchBar.setScopeBarButtonTitleTextAttributes([NSForegroundColorAttributeName:colorWhite], for: .selected)
    searchBar.tintColor = colorWhite
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    self.navigationController? .setNavigationBarHidden(false, animated:true)
    let backButton = UIButton(type: UIButtonType.custom)
    backButton.addTarget(self, action: #selector(SearchTableViewController.backFunction), for: UIControlEvents.touchUpInside)
    backButton.setTitle("< Voltar", for: UIControlState())
    backButton.sizeToFit()
    let backButtonItem = UIBarButtonItem(customView: backButton)
    self.navigationItem.leftBarButtonItem = backButtonItem
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func backFunction() {
    self.navigationController?.popViewController(animated: true)
  }
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    switch selectedMode {
    case .all:
      return 6
    case .local:
      return 2
    default:
      return 1
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch selectedMode {
    case .all:
      if isOneTimeSearched && searchRadios.count == 0 && searchGenre.count == 0 && searchStates.count == 0 && searchCities.count == 0 && searchUsers.count == 0 {
        return 0
      }
      switch section {
      case 0:
        if searchRadios.count <= 3 {
          if searchRadios.count == 0 {
            if !isOneTimeSearched {
              return 0
            } else {
              return 1
            }
          } else {
            return searchRadios.count+1
          }
        } else {
          return 4+1
        }
      case 1:
        if searchGenre.count <= 3 {
          if searchGenre.count == 0 {
            if !isOneTimeSearched {
              return 0
            } else {
              return 1
            }
          }
          return searchGenre.count
        } else {
          return 4
        }
      case 2:
        if searchStates.count <= 3 {
          if searchGenre.count == 0 {
            if !isOneTimeSearched {
              return 0
            } else {
              return 1
            }
          }
          return searchStates.count
        } else {
          return 4
        }
      case 3:
        if searchCities.count <= 3 {
          if searchCities.count == 0 {
            if !isOneTimeSearched {
              return 0
            } else {
              return 1
            }
          }
          return searchCities.count
        } else {
          return 4
        }
      case 4:
        if searchUsers.count <= 3 {
          if searchUsers.count == 0 {
            if !isOneTimeSearched {
              return 0
            } else {
              return 1
            }
          }
          return searchUsers.count
        } else {
          return 4
        }
      case 5:
        if !(searchRadios.count == 0 && searchGenre.count == 0 && searchStates.count == 0 && searchCities.count == 0 && searchUsers.count == 0) {
          return 1
        } else {
          return 0
        }
      default:
        return 0
      }
    case .radios:
      if searchRadios.count == 0 {
        return 0
      }
      else if !radiosIsExpanted && searchRadios.count == 5  {
        return searchRadios.count + 1
      } else {
        return searchRadios.count
      }
    case .genre:
      if searchGenre.count == 0 {
        return 0
      }
      else if !genreIsExpanted  && searchGenre.count == 5 {
        return searchGenre.count + 1
      } else {
        return searchGenre.count
      }
    case .local:
      switch section {
      case 0:
        if searchStates.count == 0 {
          return 0
        }
        else if !statesIsExpanted && searchStates.count == 5  {
          return searchStates.count + 1
        } else {
          return searchStates.count
        }
      case 1:
        if searchCities.count == 0 {
          return 0
        }
        else if !citiesIsExpanted  && searchCities.count == 5  {
          return searchCities.count + 1
        } else {
          return searchCities.count
        }
      default:
        return 0
      }
    case .users:
      if searchUsers.count == 0 {
        return 0
      }
      else if !usersIsExpanted && searchUsers.count == 5 {
        return searchUsers.count + 1
      } else {
        return searchUsers.count
      }
    default:
      return 0
    }
    
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch selectedMode {
    case .all:
      switch indexPath.section {
      case 0:
        if searchRadios.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ShortDescriptionTableViewCell
          cell.labelDescr.text = "Não há rádios para mostrar com o termo pesquisado"
          cell.tag = 1000
          cell.selectionStyle = .none
          return cell
        }
        
        if indexPath.row == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "adsCell", for: indexPath) as! AdsTableViewCell
          let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
          let colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.1, green: (components?[1])!+0.1, blue: (components?[2])!+0.1, alpha: 0.2).color
          cell.adsButton.backgroundColor = colorWhite
          cell.adsButton.setBackgroundImage(UIImage(named: "logoAnuncio.png"), for: UIControlState())
          cell.selectionStyle = .none
          AdsManager.sharedInstance.setAdvertisement(.playerScreen, completion: { (resultAd) in
            DispatchQueue.main.async {
              if let imageAd = resultAd.image {
                let imageView = UIImageView(frame: cell.adsButton.frame)

                imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(imageAd)))
                cell.adsButton.setBackgroundImage(imageView.image, for: UIControlState())
              }
            }
          })
          return cell
        }
        if indexPath.row < 4 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
          cell.labelName.text = searchRadios[indexPath.row-1].name
          if let address = searchRadios[indexPath.row-1].address {
            cell.labelLocal.text = address.formattedLocal
          }
          cell.imageBig.kf.indicatorType = .activity
          cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(searchRadios[indexPath.row-1].thumbnail)))
          cell.imageSmallOne.image = UIImage(named: "heart.png")
          cell.labelDescriptionOne.text = "\(searchRadios[indexPath.row-1].likenumber)"
          cell.widthTextOne.constant = 30
          cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
          cell.labelDescriptionTwo.text = ""
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 1:
        if searchGenre.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ShortDescriptionTableViewCell
          cell.labelDescr.text = "Não há gêneros para mostrar com o termo pesquisado"
          cell.tag = 1000
          cell.selectionStyle = .none
          return cell
        }
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchGenre[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 2:
        if searchStates.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ShortDescriptionTableViewCell
          cell.labelDescr.text = "Não há estados para mostrar com o termo pesquisado"
          cell.tag = 1000
          cell.selectionStyle = .none
          return cell
        }
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchStates[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 3:
        if searchCities.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ShortDescriptionTableViewCell
          cell.labelDescr.text = "Não há cidades para mostrar com o termo pesquisado"
          cell.tag = 1000
          cell.selectionStyle = .none
          return cell
        }
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchCities[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 4:
        if searchUsers.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "descrCell", for: indexPath) as! ShortDescriptionTableViewCell
          cell.labelDescr.text = "Não há usuários para mostrar com o termo pesquisado"
          cell.tag = 1000
          cell.selectionStyle = .none
          return cell
        }
        if indexPath.row < 3 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
          cell.nameUser.text = searchUsers[indexPath.row].name
          cell.localUser.text = searchUsers[indexPath.row].shortAddress
          if searchUsers[indexPath.row].userImage  == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf.indicatorType = .activity
            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(searchUsers[indexPath.row].userImage)))
          }
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          return cell
        }
      case 5:
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.tag = 999
        return cell
      default:
        break
      }
    case .local:
      switch indexPath.section {
      case 0:
        if !statesIsExpanted {
          if indexPath.row < 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
            cell.labelTitle.text = searchStates[indexPath.row].name
            return cell
          } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
            cell.tag = 1061
            return cell
          }
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchStates[indexPath.row].name
          return cell
        }
      case 1:
        if !citiesIsExpanted {
          if indexPath.row < 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
            cell.labelTitle.text = searchCities[indexPath.row].name
            return cell
          } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
            cell.tag = 1060
            return cell
          }
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchCities[indexPath.row].name
          return cell
        }
      default:
        let cell = UITableViewCell()
        return cell
      }
    case .genre:
      
      if !genreIsExpanted {
        if indexPath.row < 5 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
          cell.labelTitle.text = searchGenre[indexPath.row].name
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          cell.tag = 1059
          return cell
        }
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell", for: indexPath) as! SimpleFlagTableViewCell
        cell.labelTitle.text = searchGenre[indexPath.row].name
        return cell
      }
    case .radios:
      if !radiosIsExpanted {
        if indexPath.row < 5 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
          cell.labelName.text = searchRadios[indexPath.row].name
          if let address = searchRadios[indexPath.row].address {
            cell.labelLocal.text = address.formattedLocal
          }
          cell.imageBig.kf.indicatorType = .activity
          cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(searchRadios[indexPath.row].thumbnail)))
          cell.imageSmallOne.image = UIImage(named: "heart.png")
          cell.labelDescriptionOne.text = "\(searchRadios[indexPath.row].likenumber)"
          cell.widthTextOne.constant = 30
          cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
          cell.labelDescriptionTwo.text = ""
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          cell.tag = 1058
          return cell
        }
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
        cell.labelName.text = searchRadios[indexPath.row].name
        if let address = searchRadios[indexPath.row].address {
          cell.labelLocal.text = address.formattedLocal
        }
        cell.imageBig.kf.indicatorType = .activity
        cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(searchRadios[indexPath.row].thumbnail)))
        cell.imageSmallOne.image = UIImage(named: "heart.png")
        cell.labelDescriptionOne.text = "\(searchRadios[indexPath.row].likenumber)"
        cell.widthTextOne.constant = 30
        cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
        cell.labelDescriptionTwo.text = ""
        return cell
      }
    case .users:
      if !usersIsExpanted {
        if indexPath.row < 5 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
          cell.nameUser.text = searchUsers[indexPath.row].name
          cell.localUser.text = searchUsers[indexPath.row].shortAddress
          if searchUsers[indexPath.row].userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf.indicatorType = .activity
            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(searchUsers[indexPath.row].userImage)))
          }
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "readMoreCell", for: indexPath) as! ReadMoreTableViewCell
          cell.tag = 1057
          return cell
        }
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        cell.nameUser.text = searchUsers[indexPath.row].name
        cell.localUser.text = searchUsers[indexPath.row].shortAddress
        if searchUsers[indexPath.row].userImage == "avatar.png" {
          cell.imageUser.image = UIImage(named: "avatar.png")
        } else {
          cell.imageUser.kf.indicatorType = .activity
          cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(searchUsers[indexPath.row].userImage)))
        }
        return cell
      }
    default:
      break
    }
    let cell = UITableViewCell()
    cell.tag = 999
    return cell
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    
    
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    print(searchController.searchBar.text)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    print(searchBar.text!)
    searchBar.resignFirstResponder()
    view.endEditing(true)
    let manager = RequestManager()
    AdsInfo.test(navigationController!, text: searchBar.text!) { (result) in
      if result {
        manager.searchWithWord(searchBar.text!) { (searchRequestResult) in
          print(searchRequestResult)
          self.searchAll = searchRequestResult
          let radios =  self.searchAll[.radios]
          let genres =  self.searchAll[.genre]
          let cities =  self.searchAll[.cities]
          let states =  self.searchAll[.states]
          let users = self.searchAll[.users]
          self.searchRadios = radios as! [RadioRealm]
          self.searchGenre = genres as! [GenreRealm]
          self.searchCities = cities as! [CityRealm]
          self.searchStates = states as! [StateRealm]
          self.searchUsers = users as! [UserRealm]
          self.tableView.reloadData()
        }
      }
    }
    isOneTimeSearched = true
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    self.tableView.reloadData()
  }
  
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    switch selectedScope {
    case 0:
      selectedMode = .all
      break
    case 1:
      selectedMode = .radios
      break
    case 2:
      selectedMode = .genre
      break
    case 3:
      selectedMode = .local
      break
    case 4:
      selectedMode = .users
      break
    default:
      break
    }
    tableView.reloadData()
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let tag = tableView.cellForRow(at: indexPath)?.tag
    if tag == 1058 {
      let request = RequestManager()
      request.requestRadiosWithSearch(searchBar.text!, pageNumber: 0, pageSize: 20, completion: { (radios) in
        self.radiosIsExpanted = true
        self.searchAll[.radios] = radios
        self.searchRadios = radios
        self.tableView.reloadData()
      })
      return
    } else if tag == 1059 {
      let request = RequestManager()
      request.requestGenreWithSearch(searchBar.text!, pageNumber: 0, pageSize: 20, completion: { (genres) in
        self.genreIsExpanted = true
        self.searchAll[.genre] = genres
        self.searchGenre = genres
        self.tableView.reloadData()
      })
      return
    } else if tag == 1060 {
      let request = RequestManager()
      request.requestCitiesWithSearch(searchBar.text!, pageNumber: 0, pageSize: 20, completion: { (cities) in
        self.citiesIsExpanted = true
        self.searchAll[.cities] = cities
        self.searchCities = cities
        self.tableView.reloadData()
      })
      return
    } else if tag == 1061 {
      let request = RequestManager()
      request.requestStatesWithSearch(searchBar.text!, pageNumber: 0, pageSize: 20, completion: { (states) in
        self.statesIsExpanted = true
        self.searchAll[.states] = states
        self.searchStates = states
        self.tableView.reloadData()
      })
      return
    } else if tag == 1057 {
      let request = RequestManager()
      request.requestUsersWithSearch(searchBar.text!, pageNumber: 0, pageSize: 20, completion: { (users) in
        self.usersIsExpanted = true
        self.searchAll[.users] = users
        self.searchUsers = users
        self.tableView.reloadData()
      })
      return
    }
    if tableView.cellForRow(at: indexPath)?.tag != 1000 && tableView.cellForRow(at: indexPath)!.tag != 999 {
      view.addSubview(activityIndicator)
      activityIndicator.isHidden = false
      self.tableView.allowsSelection = false
      switch selectedMode {
      case .all:
        switch indexPath.section {
        case 0:
          if indexPath.row == 0 {
            
          }
          else if indexPath.row == 4 {
            selectedMode = .radios
            searchBar.selectedScopeButtonIndex = 1
            tableView.reloadData()
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
          }
            
          else if indexPath.row >= 1 && indexPath.row <= 3 {
            selectedRadio = searchRadios[indexPath.row-1]
            DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
          }
        case 1:
          if indexPath.row == 3 {
            selectedMode = .genre
            searchBar.selectedScopeButtonIndex = 2
            tableView.reloadData()
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
          } else {
            let genre = searchGenre[indexPath.row]
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            let manager = RequestManager()
            manager.requestRadiosInGenre(genre.id,pageNumber: 0,pageSize: 20) { (resultGenre) in
              genre.updateRadiosOfGenre(resultGenre)
              self.tableView.allowsSelection = true
              self.activityIndicator.isHidden = true
              self.activityIndicator.removeFromSuperview()
              for radio in resultGenre {
                radio.setRadioGenre(DataManager.sharedInstance.allMusicGenre[indexPath.row].name)
              }
              DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: resultGenre,title:genre.name)
            }
          }
        case 2:
          if indexPath.row == 3 {
            selectedMode = .local
            searchBar.selectedScopeButtonIndex = 3
            tableView.reloadData()
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
          } else {
            let state = searchStates[indexPath.row]
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
            DataManager.sharedInstance.instantiateCitiesInStateView(navigationController!, state: state)
          }
        case 3:
          if indexPath.row == 3 {
            selectedMode = .local
            searchBar.selectedScopeButtonIndex = 3
            tableView.reloadData()
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
          } else {
            
            let city = searchCities[indexPath.row]
            let manager = RequestManager()
            manager.requestRadiosInCity(city.id,pageNumber: 0,pageSize: 10, completion: { (resultCity) in
              city.updateRadiosOfCity(resultCity)
              self.tableView.allowsSelection = true
              self.activityIndicator.isHidden = true
              self.activityIndicator.removeFromSuperview()
              DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: Array(city.radios),title:city.name)
            })
            
            
          }
        case 4:
          if indexPath.row == 3 {
            selectedMode = .users
            searchBar.selectedScopeButtonIndex = 4
            tableView.reloadData()
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            self.tableView.allowsSelection = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
          } else {
            let user = searchUsers[indexPath.row]
            self.tableView.allowsSelection = true
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            DataManager.sharedInstance.instantiateUserDetail(navigationController!, user: user)
          }
        default:
          break
        }
      case .radios:
        selectedRadio = searchRadios[indexPath.row]
        DataManager.sharedInstance.instantiateRadioDetailView(navigationController!, radio: selectedRadio)
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        self.tableView.allowsSelection = true
      case .local:
        switch indexPath.section {
        case 0:
          let state = searchStates[indexPath.row]
          self.activityIndicator.isHidden = true
          self.activityIndicator.removeFromSuperview()
          self.tableView.allowsSelection = true
          DataManager.sharedInstance.instantiateCitiesInStateView(navigationController!, state: state)
        case 1:
          let city = searchCities[indexPath.row]
          let manager = RequestManager()
          manager.requestRadiosInCity(city.id,pageNumber: 0,pageSize: 30, completion: { (resultCity) in
            city.updateRadiosOfCity(resultCity)
            self.tableView.allowsSelection = true
            self.activityIndicator.isHidden = true
            self.activityIndicator.removeFromSuperview()
            DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: Array(city.radios),title:city.name)
          })
        default:
          break
        }
      case .genre:
        let genre = searchGenre[indexPath.row]
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        let manager = RequestManager()
        manager.requestRadiosInGenre(genre.id,pageNumber: 0,pageSize: 20) { (resultGenre) in
          genre.updateRadiosOfGenre(resultGenre)
          self.tableView.allowsSelection = true
          self.activityIndicator.isHidden = true
          self.activityIndicator.removeFromSuperview()
          for radio in resultGenre {
            radio.setRadioGenre(DataManager.sharedInstance.allMusicGenre[indexPath.row].name)
          }
          DataManager.sharedInstance.instantiateListOfRadios(self.navigationController!, radios: resultGenre,title:genre.name)
        }
      case .users:
        let user = searchUsers[indexPath.row]
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateUserDetail(navigationController!, user: user)
      default:
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        self.tableView.allowsSelection = true
        break
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch selectedMode {
    case .local:
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
    case .all:
      if searchRadios.count + searchCities.count + searchStates.count + searchGenre.count + searchCities.count + searchUsers.count > 0 {
        switch section {
        case 0:
          return "Rádios"
        case 1:
          return "Gêneros"
        case 2:
          return "Estados"
        case 3:
          return "Cidades"
        case 4:
          return "Usuários"
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
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if !isOneTimeSearched {
      str = "Realize uma pesquisa acima"
      let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
      return NSAttributedString(string: str, attributes: attr)
    } else {
      
      if selectedMode == .all {
        str = "Nenhum resultado encontrado"
      } else if selectedMode == .genre {
        str = "Nenhum gênero foi encontrado"
      } else if selectedMode == .local {
        str = "Nenhum local foi encontrado"
      } else if selectedMode == .radios {
        str = "Nenhuma rádio foi reproduzida"
      } else if selectedMode == .users {
        str = "Nenhum usuário foi encontrado"
      } else {
        str = "Nenhuma rádio para mostrar"
      }
    }
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    if !isOneTimeSearched {
      str = ""
      let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
      return NSAttributedString(string: str, attributes: attr)
    } else {
      
      if selectedMode == .all {
        str = "Tente digitar outro termo"
      } else if selectedMode == .genre {
        str = "Tente digitar outro termo"
      } else if selectedMode == .local {
        str = "Tente digitar outro termo"
      } else if selectedMode == .radios {
        str = "Tente digitar outro termo"
      } else if selectedMode == .users {
        str = "Tente digitar outro termo"
      } else {
        str = ""
      }
    }
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "logo-cinzaAbert-1.png")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
}
