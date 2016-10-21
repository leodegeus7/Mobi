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


class GracenoteManager: NSObject,GnLookupLocalStreamIngestEventsDelegate,GnStatusEventsDelegate,GnMusicIdStreamEventsDelegate,GnMusicIdFileEventsDelegate {

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
    gnManager = try! GnManager(license:licenseString as String, licenseInputMode:kLicenseInputModeString)
    
    gnUserStore = GnUserStore()
    gnUser = try! GnUser(userStoreDelegate: gnUserStore, clientId: clientId, clientTag: clientTag, applicationVersion: applicationVersion)
    
    
    
    musicId = try GnMusicId(user: gnUser, statusEventsDelegate: self)
  
  }
  
  func findMatch(albumTitle:String,trackTitle:String,albumArtistName:String,trackArtistName:String,composerName:String,completion: (resultGracenote: Music) -> Void) {
    do {
      let info = try! musicId.findAlbumsWithAlbumTitle(albumTitle, trackTitle: trackTitle, albumArtistName: albumArtistName, trackArtistName: trackArtistName, composerName: composerName)
      if let albumTeste = info.albums().allObjects().first {
        let albumTeste2:GnAlbum = albumTeste as! GnAlbum

        
        if let image = albumTeste2.content(kContentTypeImageCover)?.asset(kImageSizeSmall)?.url() {
          print(image)
        } else {
          print("nil")
        }
        if let image = albumTeste2.coverArt()?.asset(kImageSizeSmall)!.url() {
          print(image)
        } else {
          print("nil")
        }
        if let image = albumTeste2.artist()?.contributor()?.image()?.asset(kImageSizeSmall)!.url() {
          print(image)
        } else {
          print("nil")
        }
        
        let musicGracenote = Music(name: (albumTeste2.tracksMatched().allObjects().first?.title()?.display())!, albumName: (albumTeste2.title()?.display())!, composer: (albumTeste2.artist()?.name()?.display())!, coverArt: UIImage())
        completion(resultGracenote: musicGracenote)
      }

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
    switch (status)
    {
    case  kStatusProcessingInvalid:
      break
    case   kStatusProcessingAudioNone:
      break
    case kStatusProcessingAudioStarted:
      dispatch_async(dispatch_get_main_queue()) {

      }
      break
    case   kStatusProcessingAudioEnded:
      break
    case  kStatusProcessingAudioSilence:
      break
    case  kStatusProcessingAudioNoise:
      break
    case kStatusProcessingAudioSpeech:
      break
    case  kStatusProcessingAudioMusic:
      break
    case  kStatusProcessingTransitionNone:
      break
    case  kStatusProcessingTransitionChannelChange:
      break
    case  kStatusProcessingTransitionContentToContent:
      break
    case kStatusProcessingErrorNoClassifier:
      break
    default:
      break
    }

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
    switch(status)
    {
    case kIngestStatusInvalid:
      NSLog("status = kIngestStatusInvalid");
      break;
    case kIngestStatusItemBegin:
      NSLog("status = kIngestStatusItemBegin");
      break;
    case kIngestStatusItemAdd:
      NSLog("status = kIngestStatusItemAdd");
      break;
    case kIngestStatusItemDelete:
      NSLog("status = kIngestStatusItemDelete");
      break;
    default:
      NSLog("status = unknown");
    }
  }
  
  func statusEvent(status: GnStatus, percentComplete: UInt, bytesTotalSent: UInt, bytesTotalReceived: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    var statusString:String = "";
    
    
    switch (status)
    {
    case kStatusUnknown:
      statusString = "Status Unknown"
      break
      
    case  kStatusBegin:
      statusString = "Status Begin"
      break
      
    case kStatusProgress:
      break
      
    case  kStatusComplete:
      statusString = "Status Complete"
      break
      
    case kStatusErrorInfo:
      statusString = "No Match";
      break;
      
    case kStatusConnecting:
      statusString = "Status Connecting"
      break;
      
    case kStatusSending:
      statusString = "Status Sending"
      break;
      
    case kStatusReceiving:
      statusString = "Status Receiving"
      break;
      
    case kStatusDisconnected:
      statusString = "Status Disconnected"
      break;
      
    case kStatusReading:
      statusString = "Status Reading"
      break;
      
    case kStatusWriting:
      statusString = "Status Writing"
      break;
      
    case kStatusCancelled:
      statusString = "Status Cancelled"
      break;
      
    default:
      break
    }
  }
  
  func musicIdFileComplete(completeError: NSError) {
    print(completeError)
  }
  
  func musicIdFileResultNotFound(fileInfo: GnMusicIdFileInfo, currentFile: UInt, totalFiles: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
  
  func musicIdFileAlbumResult(albumResult: GnResponseAlbums, currentAlbum: UInt, totalAlbums: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    print(albumResult)
  }
  
  func musicIdFileMatchResult(matchesResult: GnResponseDataMatches, currentAlbum: UInt, totalAlbums: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    print(matchesResult)
  }
  
  func musicIdFileStatusEvent(fileInfo: GnMusicIdFileInfo, status: GnMusicIdFileCallbackStatus, currentFile: UInt, totalFiles: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    
  }
  
  func gatherMetadata(fileInfo: GnMusicIdFileInfo, currentFile: UInt, totalFiles: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    print(fileInfo)
  }
  
  func gatherFingerprint(fileInfo: GnMusicIdFileInfo, currentFile: UInt, totalFiles: UInt, cancellableDelegate canceller: GnCancellableDelegate) {
    print(fileInfo)
  }
  
}
