//
//  GracenoteManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 10/17/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import MediaPlayer


class GracenoteManager: NSObject,GnLookupLocalStreamIngestEventsDelegate,GnStatusEventsDelegate,GnMusicIdStreamEventsDelegate {

  let CLIENT_ID_Gnsdk = "148764300"
  let CLIENT_TAG_Gnsdk = "78D9186EB2545D0EC03954099C72F4F2"
  let LICENSE_Gnsdk = "license.txt"
  let APP_VERSION = "1.0.0.0"
  
  var gnManager:GnManager!
  var gnUser:GnUser!
  var gnUserStore:GnUserStore!
  var gnMusicIdStream:GnMusicIdStream!
  var queryBeginTimeInterval:NSTimeInterval!
  var queryEndTimeInterval:NSTimeInterval!
  var cancellableObjects:NSMutableArray!
  var musicId:GnMusicId!
  
  convenience init(bool:Bool) {
    self.init()
    do
    {
      try initializeGnsdk( clientId:self.CLIENT_ID_Gnsdk, clientTag:self.CLIENT_TAG_Gnsdk, license:self.LICENSE_Gnsdk, applicationVersion:self.APP_VERSION )
    }
    catch
    {
      print("\(error)")
    }
  }
  
  func initializeGnsdk( clientId clientId:String, clientTag:String, license:String, applicationVersion:String ) throws
  {
    let licensePath = NSBundle.mainBundle().pathForResource(license, ofType: nil)
    
    let licenseString = try! NSString.init(contentsOfFile: licensePath!, encoding: NSUTF8StringEncoding)
    gnManager = try! GnManager( license:licenseString as String, licenseInputMode:kLicenseInputModeString)
    
    gnUserStore = GnUserStore()
    gnUser = try! GnUser(userStoreDelegate: gnUserStore, clientId: clientId, clientTag: clientTag, applicationVersion: applicationVersion)
    
    
    
    musicId = try GnMusicId(user: gnUser, statusEventsDelegate: self)
    gnMusicIdStream = try! GnMusicIdStream(user: gnUser, preset: kPresetRadio, musicIdStreamEventsDelegate: self)
    
    let gnMusicIdStreamOptions = gnMusicIdStream.options()
    try gnMusicIdStreamOptions.resultSingle(true)
    try gnMusicIdStreamOptions.preferResultCoverart(true)

    queryBeginTimeInterval = NSDate().timeIntervalSince1970
  
  }
  
  func findMatch(albumTitle:String,trackTitle:String,albumArtistName:String,trackArtistName:String,composerName:String) {
    do {
      let info = try musicId.findMatches(albumTitle, trackTitle: trackTitle, albumArtistName: albumArtistName, trackArtistName: trackArtistName, composerName: composerName)
      print(info.dataMatches())
    } catch let error {
      print(error)
    }
  }
  
  func musicIdStreamAlbumResult(result: GnResponseAlbums, cancellableDelegate canceller: GnCancellableDelegate)
  {
    
    print(result)
    cancellableObjects.removeObject(gnMusicIdStream)
    if cancellableObjects.count == 0
    {
      
    }
    
  }
  
  func musicIdStreamProcessingStatusEvent(status: GnMusicIdStreamProcessingStatus, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
  func musicIdStreamIdentifyingStatusEvent(status: GnMusicIdStreamIdentifyingStatus, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
  
  func musicIdStreamIdentifyCompletedWithError(completeError: NSError)
  {
    cancellableObjects.removeObject(gnMusicIdStream)
    if cancellableObjects.count == 0
    {
      
    }
  }
  
  func statusEvent(status: GnLookupLocalStreamIngestStatus, bundleId: String, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
  
  func statusEvent(status: GnStatus, percentComplete: UInt, bytesTotalSent: UInt, bytesTotalReceived: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
}
