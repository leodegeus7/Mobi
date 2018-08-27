//
//  DataManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/8/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import RealmSwift
import Firebase
import AVFoundation



enum NSComparisonResult : Int {
  case orderedAscending
  case orderedSame
  case orderedDescending
}

enum SearchMode {
  case all
  case radios
  case genre
  case local
  case states
  case cities
  case users
}

enum PostType : Int {
  case text = 0
  case image = 1
  case audio = 2
  case video = 3
  case undefined = -1
}

enum StreamingLinkType : Int {
  case low = 0
  case high = 1
  case rds = 2
  case undefined = -1
  case audio = 3
}

enum StremingQuality : Int {
  case automatic = 0
  case low = 1
  case high = 2
  case undefined = 3
}

enum StatusApp : Int {
  case correctyStatus = 0
  case problemWithRealm = 1
  case problemWithServer = 2
  case problemWithInternet = 3
}

struct MusicRadio {
  var radio:RadioRealm!
  var music:Music!
}

struct City {
  var name:String
  var id:Int
}


class DataManager: NSObject {

static let sharedInstance = DataManager()

  var configApp:AppConfigRealm!
  
  var statusApp:StatusApp = .correctyStatus
  
  let baseURL = "https://wsmobi.mobiabert.com.br:8180/radiocontrole-web/api/"
  //let baseURL = "http://feroxhome.mooo.com:8080/radiocontrole-web/api/"
  var userToken = ""
  var myUser = UserRealm()
  var userLocation:CLLocation!
  var audioConfig:AudioConfig!
  var realm:Realm!
  
  var isLoadScreenAppered = false
  
  //Groups of radios
  var allRadios = [RadioRealm]()
  var topRadios = [RadioRealm]()
  var favoriteRadios = [RadioRealm]()
  var recentsRadios = [RadioRealm]()
  var localRadios = [RadioRealm]()
  
  var allMusicGenre = [GenreRealm]()
  var allStates = [StateRealm]()
  
  var isPlay = false
  var radioInExecution = RadioRealm()
  var musicInExecution = Music()
  
  var lastMusicRadio:MusicRadio!
  
  var allNews = [New]()
  var addressId = 0
  
  var isLogged = false
  
  var sleepTimer = Timer()
  var isSleepModeEnabled  = false
  var dateSleep = Date()
  
  var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
  
  var advertisement = [Advertisement]()
  var isAdsRequested = false
  
  var navigationController = UINavigationController()
  
  var avPlayer: AVAudioPlayer!
  
  var images = [ImageManager]()
  
  var blueColor:ColorRealm!
  var pinkColor:ColorRealm!
  
  var menuIsOpen = false
  var menuClose = true
  
  struct ProgramDays {
    var isSunday:Bool
    var isMonday:Bool
    var isTuesday:Bool
    var isWednesday:Bool
    var isThursday:Bool
    var isFriday:Bool
    var isSaturday:Bool
  }
  
  enum actualCondition {
    case ok
    case without
  }
  
  var firMessagingToken = ""
  var miniPlayerView = MiniPlayerViewController()
  var playerClass:PlayerViewController!
  
  var interfaceColor = ColorRealm()
  var existInterfaceColor = false
  
  var needUpdateMenu = true
  

  
  func updateRadioDistance() {
    for radio in localRadios {
      radio.resetDistanceFromUser()
    }
    localRadios.sort(by: { $0.distanceFromUser < $1.distanceFromUser })
  }
  
  func updateAllOverdueInterval() {
    for radio in recentsRadios {
      radio.updateOverdueInterval()
    }
    //EM MANUTENÇÃO - PRECISA PUXAR OS RECENTES DO SERVIDOR
//    if DataManager.sharedInstance.recentsRadios.count > 0 {
//      if recentsRadios[0].lastAccessDate != nil {
//        recentsRadios.sortInPlace({ $0.lastAccessDate.compare($1.lastAccessDate) == .OrderedDescending })
//      }
//    }
  }
  
  
  func instantiateSearch(_ navigation:UINavigationController) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "searchView") as? SearchTableViewController
    navigation.pushViewController(vc!, animated: true)
  }
  
  func instantiateRadioDetailView(_ navigation:UINavigationController,radio:RadioRealm) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "radioTableDetail") as? RadioTableViewController
    vc?.actualRadio = radio
    
    let backButton = UIBarButtonItem()
    backButton.title = "Voltar"
    navigation.navigationItem.backBarButtonItem = backButton
    
    navigation.pushViewController(vc!, animated: true)
  }
  
  func instantiateListOfRadios(_ navigation:UINavigationController,radios:[RadioRealm],title:String) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "radioListView") as? RadioListTableViewController
    vc?.radios = radios
    vc?.title = title
    navigation.pushViewController(vc!, animated: true)
  }
  
  func instantiateCitiesInStateView(_ navigation:UINavigationController,state:StateRealm) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "citiesView") as? LocalCities2TableViewController
    vc?.selectedState = state
    navigation.pushViewController(vc!, animated: true)
  }
  
  func instantiateListOfUsers(_ navigation:UINavigationController,userList:[UserRealm],title:String) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "userView") as? UsersListTableViewController
    vc?.actualUsers = userList
    vc?.viewTitle = title
    navigation.pushViewController(vc!, animated: true)
  }
  
  func instantiateProfile(_ navigation:UINavigationController) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController
    navigation.pushViewController(vc!, animated: true)
  }

  func instantiateUserDetail(_ navigation:UINavigationController, user:UserRealm) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "userDetailView") as? UserDetailTableViewController
    vc!.actualUser = user
    vc!.viewTitle = user.name
    navigation.pushViewController(vc!, animated: true)
  }
  
  func instantiateSubCommentView(_ navigation:UINavigationController, comment:Comment) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "commentsView") as? CommentsTableViewController
    vc!.actualComment = comment
    vc!.actualRadio = comment.radio
    navigation.pushViewController(vc!, animated: true)
  }
  
  
  //  func updateAddressFromRadios(index:Int,radios:[Radio],completion: (resultAddress: Bool) -> Void) -> Bool { //sempre mandar 0 no index para chamar esta função
  //    if radios.count < index {
  //      if radios[index].address.currentClassState != .CompleteAddress {
  //        Address.getAddress(radios[index].address, completion: { (resultAddress) in
  //          self.updateAddressFromRadios(index+1, radios: radios, completion: completion)
  //      })
  //      }
  //      return false
  //    } else {
  //      return true
  //    }
  //  }
  
}

