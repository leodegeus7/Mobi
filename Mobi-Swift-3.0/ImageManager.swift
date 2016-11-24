//
//  ImageManager.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/23/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class ImageManager: NSObject {
  
  enum ImageState {
    case NoImage
    case Retrieving
    case Downloading
    case ErrorDownloading
    case ImageOk
  }
  var imageFile:UIImage!
  var imageCacheName = ""
  var urlImage = ""
  var state:ImageState = .NoImage
  var progressImageDownload:CGFloat = 0.0
  var errorMessage:String!
  var cellIsReloaded = false
  var cellIsProcessing = false
  var sizeImage:CGSize!
  var indexPathCell:NSIndexPath!
  
  func setImage(imageCacheName:String,urlImage:String,completion: (imageReturn: UIImage) -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      if self.state != .ImageOk {
        self.state = .Retrieving
        self.imageCacheName = imageCacheName
        self.urlImage = urlImage
        ImageCache.defaultCache.retrieveImageForKey(imageCacheName, options: []) { (image, cacheType) in
          if let _ = image {
            self.imageFile = image!
            self.state == .ImageOk
            completion(imageReturn: image!)
          } else {
            if urlImage != "" {
              self.state = .Downloading
              ImageDownloader.defaultDownloader.downloadImageWithURL(NSURL(string: urlImage)!, options: [], progressBlock: { (receivedSize, totalSize) in
                self.progressImageDownload = CGFloat(receivedSize/totalSize)
                }, completionHandler: { (image, error, imageURL, originalData) in
                  if let errorMessage = error {
                    self.errorMessage = errorMessage.localizedDescription
                    print("Erro para baixar imagem \(imageCacheName) com erro \(error?.code) e descrição \(error?.localizedDescription)")
                    self.state = .ErrorDownloading
                  }
                  if let _ = image {
                    ImageCache.defaultCache.storeImage(image!, forKey: imageCacheName)
                    self.imageFile = image!
                    self.state = .ImageOk
                    completion(imageReturn: image!)
                  }
              })
            }
          }
        }
      } else {
        
        if let _ = self.imageFile {
          completion(imageReturn: self.imageFile)
        } else {
          ImageCache.defaultCache.retrieveImageForKey(imageCacheName, options: []) { (image, cacheType) in
            if let _ = image {
              self.imageFile = image!
              completion(imageReturn: image!)
            } else {
              
            }
          }
        }
      }
    })
  }
  
  func setImageInWallCell(tableView:UITableView,indexPath:NSIndexPath,cell:WallImageTableViewCell, imageCacheName:String,urlImage:String,completion: (imageReturn: UIImage) -> Void) {
    if !cellIsProcessing {
      cellIsProcessing = true
      indexPathCell = indexPath
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
      cell.stateImage = .Retrieving
      self.setImage(imageCacheName, urlImage: urlImage, completion: { (imageReturn) in
        if !self.cellIsReloaded {
          
          if self.state == .ImageOk {
            dispatch_async(dispatch_get_main_queue(), {
              cell.imageInCell = imageReturn
              if indexPath.row == cell.tag {
                let ratio = (imageReturn.size.height)/(imageReturn.size.width)
                if imageReturn.size.height > 600 {
                  cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: 600)
                  cell.heightImage.constant = 600
                  cell.sizeImage = CGSize(width: cell.frame.width, height: 600)
                } else {
                  
                  cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: ratio*cell.frame.width)
                  cell.heightImage.constant = ratio*cell.frame.width
                  cell.sizeImage = CGSize(width: cell.frame.width, height: ratio*cell.frame.width)
                }
                cell.imageInCell = imageReturn
                
                cell.widthImage.constant = cell.frame.width
                self.imageFile = imageReturn
                cell.imageObject = self
                cell.imageAttachment.image = imageReturn
                DataManager.sharedInstance.images.append(self)
                tableView.reloadRowsAtIndexPaths([self.indexPathCell], withRowAnimation: .Automatic)
              }
            })
          } else {
            dispatch_async(dispatch_get_main_queue(), {
              if indexPath.row == cell.tag {
                let indexPathCell = tableView.indexPathForCell(cell)
                cell.imageAttachment.image = UIImage(named: "anuncio.png")
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
              }
            })
            
          }
          self.cellIsReloaded = true
        }
      })
    })
    }
  }
}
