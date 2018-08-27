//
//  AdsManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/25/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import GameplayKit

class AdsManager: NSObject {
  
    static let sharedInstance = AdsManager()
  
  var advertisement = [Advertisement]()
  var isAdsRequested = false
  var timeWasRequested:Date!
  
  internal enum ScreenName {
    case playerScreen
    case profileScreen
    case searchScreen
  }
  

  
  func setAdvertisement(_ screenName:ScreenName,completion: @escaping (_ resultAd: Advertisement) -> Void) {
    requestAllAds { (resultAd) in
      completion(self.findCorrectAd(screenName))
    }
  }
  
  func requestAllAds(_ completion: @escaping (_ resultAd: [Advertisement]) -> Void) {
    if isAdsRequested {
      if Date().timeIntervalSince(timeWasRequested) > 120 {    //tento manter um intervalo de 120 segundos em cada requisição de request
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async { //trabalhando no threat de background
          let adsRequest = RequestManager()
          adsRequest.requestAdvertisement { (result) in
            self.advertisement = result
            self.timeWasRequested = Date()
            completion(self.advertisement)
          }
        }
      } else {
        completion(advertisement)
      }
    } else {
      DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        let adsRequest = RequestManager()
        adsRequest.requestAdvertisement { (result) in
          self.advertisement = result
          self.isAdsRequested = true
          self.timeWasRequested = Date()
          completion(self.advertisement)
        }
      }
    }
  }
  
  func findCorrectAd(_ screenName:ScreenName) -> Advertisement {
    let suffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: advertisement) as! [Advertisement] //em caso que existam ads que utilizem a mesma tela e estejam no mesmo período de tempo, faço um shuffle no array para sempre variar qual ad mostrar - SITUAÇÃO IMPOSSÍVEL
    switch screenName {
    case .playerScreen:
      for ad in suffledArray {
        if ad.playerScreen {
          if adIsInDateInterval(ad) {
            return ad
          }
        }
      }
    case .profileScreen:
      for ad in suffledArray {
        if ad.profileScreen {
          if adIsInDateInterval(ad) {
            return ad
          }
        }
      }
    case .searchScreen:
      for ad in suffledArray {
        if ad.searchScreen {
          if adIsInDateInterval(ad) {
            return ad
          }
        }
      }
    }
    return Advertisement()
  }
  
  func adIsInDateInterval(_ ad:Advertisement) -> Bool {
    if let dateEnd = ad.datetimeEnd {
      if dateEnd.timeIntervalSinceNow > 0 && ad.datetimeStart.timeIntervalSinceNow < 0 {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }
}
