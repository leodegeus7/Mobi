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
  
  var advertisement = [Advertisement]()
  var isAdsRequested = false
  var timeWasRequested:NSDate!
  
  internal enum ScreenName {
    case PlayerScreen
    case ProfileScreen
    case SearchScreen
  }
  
  class var sharedInstance: AdsManager {
    struct Static {
      static var instance: AdsManager?
      static var token: dispatch_once_t = 0
    }
    dispatch_once(&Static.token) {
      Static.instance = AdsManager()
    }
    return Static.instance!
  }
  
  func setAdvertisement(screenName:ScreenName,completion: (resultAd: Advertisement) -> Void) {
    requestAllAds { (resultAd) in
      completion(resultAd: self.findCorrectAd(screenName))
    }
  }
  
  func requestAllAds(completion: (resultAd: [Advertisement]) -> Void) {
    if isAdsRequested {
      if NSDate().timeIntervalSinceDate(timeWasRequested) > 120 {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
          let adsRequest = RequestManager()
          adsRequest.requestAdvertisement { (result) in
            self.advertisement = result
            self.timeWasRequested = NSDate()
            completion(resultAd: self.advertisement)
          }
        }
      } else {
        completion(resultAd: advertisement)
      }
    } else {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        let adsRequest = RequestManager()
        adsRequest.requestAdvertisement { (result) in
          self.advertisement = result
          self.isAdsRequested = true
          self.timeWasRequested = NSDate()
          completion(resultAd: self.advertisement)
        }
      }
    }
  }
  
  func findCorrectAd(screenName:ScreenName) -> Advertisement {
    let suffledArray = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(advertisement) as! [Advertisement]
    switch screenName {
    case .PlayerScreen:
      for ad in suffledArray {
        if ad.playerScreen {
          if adIsInDateInterval(ad) {
            return ad
          }
        }
      }
    case .ProfileScreen:
      for ad in suffledArray {
        if ad.profileScreen {
          if adIsInDateInterval(ad) {
            return ad
          }
        }
      }
    case .SearchScreen:
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
  
  func adIsInDateInterval(ad:Advertisement) -> Bool {
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
