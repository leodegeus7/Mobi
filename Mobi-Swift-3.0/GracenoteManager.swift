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
  var gnMic:GnMic!
  var gnUser:GnUser!
  var gnUserStore:GnUserStore!
  var gnStorageSqlite:GnStorageSqlite!
  var gnLookupLocalStream:GnLookupLocalStream!
  var gnMusicIdStream:GnMusicIdStream!
  var gnLocale:GnLocale!
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
    
    
    
    gnLocale = try GnLocale(localeGroup:kLocaleGroupMusic, language:kLanguagePortuguese, region:kRegionGlobal, descriptor:kDescriptorDefault, user:gnUser, statusEventsDelegate:nil)
    try! gnLocale.setGroupDefault()
    
    let session:AVAudioSession = AVAudioSession.sharedInstance()
    try! session.setPreferredSampleRate(44100)
    try! session.setInputGain(0.5)
    try! session.setActive(true)
    
    //    gnStorageSqlite = try! GnStorageSqlite.enable()
    //    let documentDirectoryURL =  try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    //    try! gnStorageSqlite.storageLocation(documentDirectoryURL.path!)
    //    try! setupLocalLookup(documentDirectoryURL.path)
    //    try! downloadLatestBundle()
    
    gnMusicIdStream = try GnMusicIdStream(user: gnUser, preset: kPresetRadio, locale: gnLocale, musicIdStreamEventsDelegate: self)
    let gnMusicIdStreamOptions = gnMusicIdStream.options()
    try gnMusicIdStreamOptions.resultSingle(true)
    try gnMusicIdStreamOptions.lookupData(kLookupDataSonicData, enable:true)
    try gnMusicIdStreamOptions.lookupData(kLookupDataContent, enable: true)
    try gnMusicIdStreamOptions.preferResultCoverart(true)
    queryBeginTimeInterval = NSDate().timeIntervalSince1970
    
    //musicId.findAlbumsWithAlbumTitle("Girl", trackTitle: "Happy", albumArtistName: "Pharell", trackArtistName: "", composerName: "")
  }
  
  func findMatch(albumTitle:String,trackTitle:String,albumArtistName:String,trackArtistName:String,composerName:String) {
    do {
      _ = try musicId.findMatches(albumTitle, trackTitle: trackTitle, albumArtistName: albumArtistName, trackArtistName: trackArtistName, composerName: composerName)
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
  
  
  func setupLocalLookup( location:String? ) throws
  {
    //	Initialize the local lookup so we can do local lookup queries.
    gnLookupLocalStream = try GnLookupLocalStream.enable()
    try gnLookupLocalStream.storageLocation(location!)
  }
  
  func downloadLatestBundle() throws
  {
    let BLOCK_SIZE = 1024
    if let bundlePath = NSBundle.mainBundle().pathForResource("1557", ofType: "b")
    {
      try gnLookupLocalStream.storageClear()
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                     {
                      do
                      {
                        let lookupLocalStreamIngest:GnLookupLocalStreamIngest = try GnLookupLocalStreamIngest(eventsDelegate:self)
                        let fileHandle:NSFileHandle! = NSFileHandle(forReadingAtPath:bundlePath)
                        
                        var fileData = fileHandle!.readDataOfLength(BLOCK_SIZE)
                        while fileData.length != 0
                        {
                          try lookupLocalStreamIngest.write(fileData)
                          fileData = fileHandle!.readDataOfLength(BLOCK_SIZE)
                        }
                        print("Loaded Bundle")
                      }
                      catch
                      {
                        print("\(error)")
                      }
      })
    }
  }
  
  func statusEvent(status: GnLookupLocalStreamIngestStatus, bundleId: String, cancellableDelegate canceller: GnCancellableDelegate) {
    var statusString:String;
    
  }
  
  func statusEvent(status: GnStatus, percentComplete: UInt, bytesTotalSent: UInt, bytesTotalReceived: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
}
