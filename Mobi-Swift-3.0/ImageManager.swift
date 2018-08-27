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
    case noImage
    case retrieving
    case downloading
    case errorDownloading
    case imageOk
  }
  var imageFile:UIImage!
  var imageCacheName = ""
  var urlImage = ""
  var state:ImageState = .noImage
  var progressImageDownload:CGFloat = 0.0
  var errorMessage:String!
  var cellIsReloaded = false
  var cellIsProcessing = false
  var sizeImage:CGSize!
  var indexPathCell:IndexPath!
  
  func setImage(_ imageCacheName:String,urlImage:String,completion: @escaping (_ imageReturn: UIImage) -> Void) {
    DispatchQueue.global().async {

      if self.state != .imageOk {
        self.state = .retrieving
        self.imageCacheName = imageCacheName
        self.urlImage = urlImage

        ImageCache.default.retrieveImage(forKey: imageCacheName, options: []) { (image, cacheType) in
          if let _ = image {
            self.imageFile = image!
            self.state = .imageOk
            completion(image!)
          } else {
            if urlImage != "" {
              self.state = .downloading
                ImageDownloader.default.downloadImage(with: URL(string: urlImage)!, retrieveImageTask: nil, options: [], progressBlock: { (receivedSize, totalSize) in
                     self.progressImageDownload = CGFloat(receivedSize/totalSize)
                }, completionHandler: { (image, error, imageURL, originalData) in
                    if let errorMessage = error {
                        self.errorMessage = errorMessage.localizedDescription
                        print("Erro para baixar imagem \(imageCacheName) com erro \(error?.code) e descrição \(error?.localizedDescription)")
                        self.state = .errorDownloading
                    }
                    if let _ = image {
                        ImageCache.default.store(image!, forKey: imageCacheName)
                        self.imageFile = image!
                        self.state = .imageOk
                        completion(image!)
                    }
                })
              
            }
          }
        }
      } else {
        
        if let _ = self.imageFile {
          completion(self.imageFile)
        } else {
            ImageCache.default.retrieveImage(forKey: imageCacheName, options: [], completionHandler: { (image, cacheType) in
                if let _ = image {
                    self.imageFile = image!
                    completion(image!)
                } else {
                    
                }
            })
          
        }
      }
    }
  }
  
  func setImageInWallCell(_ tableView:UITableView,indexPath:IndexPath,cell:WallImageTableViewCell, imageCacheName:String,urlImage:String,completion: (_ imageReturn: UIImage) -> Void) {
    if !cellIsProcessing {
      cellIsProcessing = true
      indexPathCell = indexPath
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
      cell.stateImage = .retrieving
      self.setImage(imageCacheName, urlImage: urlImage, completion: { (imageReturn) in
        if !self.cellIsReloaded {
          
          if self.state == .imageOk {
            DispatchQueue.main.async(execute: {
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
                tableView.reloadRows(at: [self.indexPathCell], with: .automatic)
              }
            })
          } else {
            DispatchQueue.main.async(execute: {
              if indexPath.row == cell.tag {
                let indexPathCell = tableView.indexPath(for: cell)
                cell.imageAttachment.image = UIImage(named: "anuncio.png")
                tableView.reloadRows(at: [indexPath], with: .automatic)
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
