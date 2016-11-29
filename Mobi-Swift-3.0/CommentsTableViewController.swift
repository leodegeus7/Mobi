//
//  CommentsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/3/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
  var actualRadio:RadioRealm!
  var actualComment :Comment!
  var actualSubComments : [Comment]!
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  var firstTimeToShow = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Comentários"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "plus.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(RadioTableViewController.createComment))
    let requestManager = RequestManager()
    requestManager.requestComments(actualComment, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
      self.actualSubComments = resultWall
      self.tableView.allowsSelection = true
      self.activityIndicator.hidden = true
      self.self.activityIndicator.removeFromSuperview()
      self.tableView.reloadData()
    })
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    self.clearsSelectionOnViewWillAppear = true
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func viewWillAppear(animated: Bool) {
    firstTimeToShow = true
    self.tableView.reloadData()
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    tableView.allowsSelection = false
    self.clearsSelectionOnViewWillAppear = true
    let requestManager = RequestManager()
    requestManager.requestComments(actualComment, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
      self.actualSubComments = resultWall
      self.tableView.allowsSelection = true
      self.activityIndicator.hidden = true
      self.self.activityIndicator.removeFromSuperview()
      self.tableView.reloadData()
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 2
  }
  
  func createComment() {
    if DataManager.sharedInstance.isLogged {
      performSegueWithIdentifier("createPublicacionSegue", sender: self)
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário efetuar login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let ident = (segue.identifier)!
    if ident == "createPublicacionSegue" {
      let createVC = (segue.destinationViewController as! SendPublicationViewController)
      createVC.actualMode = .Comment
      createVC.actualComment = actualComment
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if firstTimeToShow {
      return 1
    } else {
      if section == 0 {
        return 1
      } else if section == 1 {
        if actualSubComments.count == 0 {
          return 1
        } else {
          return actualSubComments.count
        }
      }
    }
    return 0
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if firstTimeToShow {
      let cell = UITableViewCell()
      firstTimeToShow = false
      return cell
    }
    else {
      if indexPath.section == 0 {
        if actualComment.postType == .Audio {
          let cell = tableView.dequeueReusableCellWithIdentifier("wallAudioCell", forIndexPath: indexPath) as! WallAudioPlayerTableViewCell
          cell.labelName.text = actualComment.user.name
          cell.selectionStyle = .None
          cell.labelDate.text = Util.getOverdueInterval(actualComment.date)
          cell.textViewWall.text = actualComment.text
          if actualComment.user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComment.user.userImage)))
          }
          cell.identifier = actualComment.audio
          return cell
          
        }
        if actualComment.postType == .Image {
          let cell = tableView.dequeueReusableCellWithIdentifier("wallImageCell", forIndexPath: indexPath) as! WallImageTableViewCell
          cell.selectionStyle = .None
          cell.labelName.text = actualComment.user.name
          cell.labelDate.text = Util.getOverdueInterval(actualComment.date)
          cell.textViewWall.text = actualComment.text
          if actualComment.user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComment.user.userImage)))
          }
          cell.buttonZoomImage.tag = indexPath.row
          cell.tag = indexPath.row
          cell.imageAttachment.kf_showIndicatorWhenLoading = true
          if !cell.isReloadCell {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
              cell.imageAttachment?.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualComment.image)), placeholderImage: UIImage(), optionsInfo: [.Transition(.Fade(0.2))], progressBlock: { (receivedSize, totalSize) in
                
                }, completionHandler: { (image, error, cacheType, imageURL) in
                  
                  dispatch_async(dispatch_get_main_queue(), {
                    
                    if let image3 = image {
                      if let image2 = image3 as? UIImage {
                        if cell.tag == indexPath.row && !cell.isReloadCell{
                          let ratio = (image2.size.height)/(image2.size.width)
                          
                          cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: ratio*cell.frame.width)
                          cell.heightImage.constant = ratio*cell.frame.width
                          cell.widthImage.constant = cell.frame.width
                          //cell.imageAttachment.image = image
                          tableView.beginUpdates()
                          tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                          tableView.endUpdates()
                          cell.tag = 1000
                          cell.isReloadCell = true
                        }
                      }
                    }
                    
                  })
              })
            })
          }
          cell.buttonZoomImage.backgroundColor = UIColor.clearColor()
          return cell
        } else {
          let cell = tableView.dequeueReusableCellWithIdentifier("wallCell", forIndexPath: indexPath) as! WallTableViewCell
          cell.selectionStyle = .None
          cell.labelName.text = actualComment.user.name
          cell.labelDate.text = Util.getOverdueInterval(actualComment.date)
          cell.textViewWall.text = actualComment.text
          
          let contentSize = cell.textViewWall.sizeThatFits(cell.textViewWall.bounds.size)
          var frame = cell.textViewWall.frame
          frame.size.height = contentSize.height
          //cell.heightText.constant = contentSize.height
          if actualComment.user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComment.user.userImage)))
          }
          return cell
        }
      } else if indexPath.section == 1 {
        if let _ = actualSubComments {
          if actualSubComments.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("noPostsCell", forIndexPath: indexPath) as! NoPostsTableViewCell
            cell.labelTitle.text = "Nenhum comentário realizada"
            cell.textViewDescription.text = "Não há nenhum comentário nesta publicação, clique no + a cima para criar"
            cell.selectionStyle = .None
            return cell
          }
        }
        if let _ = actualSubComments  {
          let cell = tableView.dequeueReusableCellWithIdentifier("wallCell", forIndexPath: indexPath) as! WallTableViewCell
          cell.labelName.text = actualSubComments[indexPath.row].user.name
          cell.labelDate.text = Util.getOverdueInterval(actualSubComments[indexPath.row].date)
          cell.textViewWall.text = actualSubComments[indexPath.row].text
          if actualSubComments[indexPath.row].user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualSubComments[indexPath.row].user.userImage)))
          }
          return cell
        } else {
          let cell = UITableViewCell()
          return cell
        }
      }
    }
    let cell = UITableViewCell()
    return cell
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Postagem atual"
    } else {
      return "Comentários sobre a postagem"
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    
    let str = "Nenhuma comentario na publicação"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    str = "Clique aqui para comentar no comentário"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    performSegueWithIdentifier("createPublicationSegue", sender: self)
  }
  
}
