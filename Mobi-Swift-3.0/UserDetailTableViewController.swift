//
//  UserDetailTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 11/16/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//

import UIKit
import Kingfisher

class UserDetailTableViewController: UITableViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  var selectedMode:UserMode = .Reviews
  enum UserMode {
    case Reviews
    case Posts
  }
  var colorBlack : UIColor!
  var colorWhite : UIColor!
  var actualUser = UserRealm()
  var viewTitle = ""
  var actualReviews = [Review]()
  var actualPosts = [Comment]()
  var actualArraySegmented = [AnyObject]()
  
  var existFollowers = false
  var existFollowing = false
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.title = viewTitle
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = true
    let components = CGColorGetComponents(DataManager.sharedInstance.interfaceColor.color.CGColor)
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: components[0]+0.1, green: components[1]+0.1, blue: components[2]+0.1, alpha: 1).color
    self.clearsSelectionOnViewWillAppear = true
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    
    let requestFollowers = RequestManager()
    let requestFollowing = RequestManager()
    let requestReviews = RequestManager()
    
    defineBarButton()
    
    requestFollowers.requestNumberOfFollowers(actualUser) { (resultNumberFollowers) in
      requestFollowing.requestNumberOfFollowing(self.actualUser, completion: { (resultNumberFollowing) in
        let detailCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DetailUserTableViewCell
        detailCell.labelFollowers.text = "\(resultNumberFollowers)"
        if resultNumberFollowers > 0 {
          self.existFollowers = true
        }
        if resultNumberFollowing > 0 {
          self.existFollowing = true
        }
        detailCell.labelFollowing.text = "\(resultNumberFollowing)"
      })
    }
    
    requestReviews.requestReviewsOfUser(actualUser, pageSize: 10, pageNumber: 0) { (resultReview) in
      self.actualReviews = resultReview
      self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
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
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if section == 0 {
      return 2
    } else {
      if selectedMode == .Reviews {
        if actualReviews.count != 0 {
          return actualReviews.count + 1
        } else {
          return 1
        }
      } else {
        if actualPosts.count != 0 {
          return actualPosts.count + 1
        } else {
          return 1
        }
      }
    }
  }
  
  @IBAction func segmentControlChanged(sender: AnyObject) {
    view.addSubview(activityIndicator)
    activityIndicator.hidden = false
    tableView.allowsSelection = false
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! SegmentedTableViewCell
    if cell.segmentedControl.selectedSegmentIndex == 0 {
      selectedMode = .Reviews
      let requestReviews = RequestManager()
      requestReviews.requestReviewsOfUser(actualUser, pageSize: 10, pageNumber: 0) { (resultReview) in
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        self.actualReviews = resultReview
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
      }
    } else {
      selectedMode = .Posts
      let requestPosts = RequestManager()
      requestPosts.requestWallOfUser(actualUser, pageNumber: 0, pageSize: 10, completion: { (resultWall) in
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        self.actualPosts = resultWall
        self.tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
      })
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        let detailCell = tableView.dequeueReusableCellWithIdentifier("detailUser", forIndexPath: indexPath) as! DetailUserTableViewCell
        if actualUser.userImage == "avatar.png" {
          detailCell.imageUser.image = UIImage(named: "avatar.png")
        } else {
          detailCell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualUser.userImage)))
        }
        detailCell.imageUser.layer.cornerRadius = detailCell.imageUser.bounds.height / 6
        detailCell.imageUser.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.CGColor
        detailCell.imageUser.layer.backgroundColor = UIColor.whiteColor().CGColor
        detailCell.imageUser.layer.borderWidth = 0
        detailCell.imageUser.clipsToBounds = true
        detailCell.labelLocal.text = actualUser.shortAddress.uppercaseString
        detailCell.labelLocal.textColor = UIColor.whiteColor()
        detailCell.backgroundColor = UIColor(gradientStyle: .TopToBottom, withFrame: detailCell.frame, andColors: [colorWhite,colorBlack])
        detailCell.labelName.text = actualUser.name.uppercaseString
        detailCell.labelName.textColor = UIColor.whiteColor()
        detailCell.labelFollowing.textColor = UIColor.whiteColor()
        detailCell.labelFollowers.textColor = UIColor.whiteColor()
        detailCell.labelIndicatorFollowers.textColor = UIColor.whiteColor()
        detailCell.labelIndicatorFollowing.textColor = UIColor.whiteColor()
        detailCell.labelIndicatorFollowing.text = "Seguindo"
        detailCell.labelIndicatorFollowers.text = "Seguidores"
        detailCell.selectionStyle = .None
        detailCell.buttonFollowers.backgroundColor = UIColor.clearColor()
        detailCell.buttonFollowing.backgroundColor = UIColor.clearColor()
        detailCell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
        detailCell.labelFollowers.text = "-"
        detailCell.labelFollowing.text = "-"
        return detailCell
      } else if indexPath.row == 1 {
        let segmentedCell = tableView.dequeueReusableCellWithIdentifier("segmentedCell", forIndexPath: indexPath) as! SegmentedTableViewCell
        segmentedCell.backgroundColor = colorBlack
        segmentedCell.segmentedControl.tintColor = UIColor.whiteColor()
        segmentedCell.segmentedControl.backgroundColor = UIColor.clearColor()
        segmentedCell.selectionStyle = .None
        segmentedCell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
        return segmentedCell
      }
    case 1:
      if selectedMode == .Posts {
        if actualPosts.count == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("noPostsCell", forIndexPath: indexPath) as! NoPostsTableViewCell
          cell.labelTitle.text = "Nenhuma publicação realizada"
          cell.textViewDescription.text = "\(actualUser.name) não realizou nenhuma publicação até o momento"
          cell.selectionStyle = .None
          return cell
        } else {
          if indexPath.row <= actualPosts.count-1 {
            if actualPosts[indexPath.row].postType == .Audio {
              let cell = tableView.dequeueReusableCellWithIdentifier("wallAudioCell", forIndexPath: indexPath) as! WallAudioPlayerTableViewCell
              cell.labelName.text = actualPosts[indexPath.row].user.name
              cell.labelDate.text = Util.getOverdueInterval(actualPosts[indexPath.row].date)
              cell.textViewWall.text = actualPosts[indexPath.row].text
              if actualPosts[indexPath.row].user.userImage == "avatar.png" {
                cell.imageUser.image = UIImage(named: "avatar.png")
              } else {
                
                cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualPosts[indexPath.row].radio.thumbnail)))
              }
              cell.identifier = actualPosts[indexPath.row].audio
              return cell
              
            }
            if actualPosts[indexPath.row].postType == .Image {
              let cell = tableView.dequeueReusableCellWithIdentifier("wallImageCell", forIndexPath: indexPath) as! WallImageTableViewCell
              cell.labelName.text = actualPosts[indexPath.row].user.name
              cell.labelDate.text = Util.getOverdueInterval(actualPosts[indexPath.row].date)
              cell.textViewWall.text = actualPosts[indexPath.row].text
              if actualPosts[indexPath.row].user.userImage == "avatar.png" {
                cell.imageUser.image = UIImage(named: "avatar.png")
              } else {
                cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualPosts[indexPath.row].radio.thumbnail)))
              }
              cell.buttonZoomImage.tag = indexPath.row
              cell.tag = indexPath.row
              cell.imageAttachment.kf_showIndicatorWhenLoading = true
              if !cell.isReloadCell {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                  cell.imageAttachment?.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualPosts[indexPath.row].image)), placeholderImage: UIImage(), optionsInfo: [.Transition(.Fade(0.2))], progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                      
                      dispatch_async(dispatch_get_main_queue(), {
                        if self.selectedMode == .Posts {
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
                        }
                      })
                  })
                })
              }
              cell.buttonZoomImage.backgroundColor = UIColor.clearColor()
              return cell
            } else {
              let cell = tableView.dequeueReusableCellWithIdentifier("wallCell", forIndexPath: indexPath) as! WallTableViewCell
              cell.labelName.text = actualPosts[indexPath.row].user.name
              cell.labelDate.text = Util.getOverdueInterval(actualPosts[indexPath.row].date)
              cell.textViewWall.text = actualPosts[indexPath.row].text
              
              let contentSize = cell.textViewWall.sizeThatFits(cell.textViewWall.bounds.size)
              var frame = cell.textViewWall.frame
              frame.size.height = contentSize.height
              cell.heightText.constant = contentSize.height
              if actualPosts[indexPath.row].user.userImage == "avatar.png" {
                cell.imageUser.image = UIImage(named: "avatar.png")
              } else {
                cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualPosts[indexPath.row].radio.thumbnail)))
              }
              return cell
            }
          } else {
            let cell = UITableViewCell()
            cell.tag = 1000
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            return cell
          }
        }
      } else if selectedMode == .Reviews {
        if actualReviews.count == 0 {
          let cell = tableView.dequeueReusableCellWithIdentifier("noPostsCell", forIndexPath: indexPath) as! NoPostsTableViewCell
          cell.labelTitle.text = "Nenhuma avaliação realizada"
          cell.textViewDescription.text = "\(actualUser.name) não realizou nenhuma avaliação até o momento"
          cell.selectionStyle = .None
          return cell
        } else {
          if indexPath.row <= actualReviews.count-1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewTableViewCell
            cell.labelName.text = actualReviews[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualReviews[indexPath.row].date)
            cell.textViewReview.text = actualReviews[indexPath.row].text
            if actualReviews[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              
              cell.imageUser.kf_setImageWithURL(NSURL(string: RequestManager.getLinkFromImageWithIdentifierString(actualReviews[indexPath.row].radio.thumbnail)))
            }
            if actualReviews[indexPath.row].score != 0 && actualReviews[indexPath.row].score != -1 {
              for index in 0...actualReviews[indexPath.row].score-1 {
                cell.stars[index].image = UIImage(named: "star.png")
                cell.stars[index].tintColor = UIColor.redColor()
              }
            }
            return cell
          } else {
            let cell = UITableViewCell()
            cell.tag = 1000
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
            return cell
          }
        }
      }
    default:
      let cell = UITableViewCell()
      cell.tag = 1000
      return cell
    }
    let cell = UITableViewCell()
    cell.tag = 1000
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView.cellForRowAtIndexPath(indexPath)?.tag != 1000 {
      if indexPath.section == 1 {
        if selectedMode == .Posts {
          DataManager.sharedInstance.instantiateSubCommentView(self.navigationController!, comment: actualPosts[indexPath.row])
        } else {
          DataManager.sharedInstance.instantiateRadioDetailView(self.navigationController!, radio: actualReviews[indexPath.row].radio)
        }
      }
    }
  }
  
  @IBAction func buttonFollowersTap(sender: AnyObject) {
    if existFollowers {
      view.addSubview(activityIndicator)
      activityIndicator.hidden = false
      tableView.allowsSelection = false
      let requestFollowers = RequestManager()
      requestFollowers.requestFollowers(actualUser, pageSize: 20, pageNumber: 0) { (resultFollowers) in
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowers, title: "Seguidores de \(self.actualUser.name)")
      }
    }
    
  }
  
  @IBAction func buttonFollowingTap(sender: AnyObject) {
    if existFollowing {
      view.addSubview(activityIndicator)
      activityIndicator.hidden = false
      tableView.allowsSelection = false
      let requestFollowing = RequestManager()
      requestFollowing.requestFollowing(actualUser, pageSize: 20, pageNumber: 0) { (resultFollowing) in
        self.tableView.allowsSelection = true
        self.activityIndicator.hidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowing, title: "Seguindo \(self.actualUser.name)")
      }
    }
  }
  
  func defineBarButton() {
    if !actualUser.isFollowing {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-add.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-remove.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
    }
  }
  
  func buttonFollowTap() {
    if DataManager.sharedInstance.isLogged {
      let manager = RequestManager()
      if !actualUser.isFollowing {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-remove.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
        actualUser.updateFollowing(true)
        manager.followUser(actualUser, completion: { (follow) in
          if !follow {
            Util.displayAlert(title: "Atenção", message: "Não foi possivel seguir o usuário \(self.actualUser.name). Contate o administrador da aplicação", action: "Ok")
          } else {
            Util.displayAlert(title: "Atenção", message: "Você esta seguindo \(self.actualUser.name) agora" , action: "Ok")
          }
        })
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-add.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.Done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
        actualUser.updateFollowing(false)
        manager.unfollowUser(actualUser, completion: { (follow) in
          if !follow {
            Util.displayAlert(title: "Atenção", message: "Não foi possivel parar de seguir o usuário \(self.actualUser.name). Contate o administrador da aplicação", action: "Ok")
          } else {
            Util.displayAlert(title: "Atenção", message: "Você não esta mais seguindo \(self.actualUser.name)" , action: "Ok")
          }
        })
      }
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário efetuar login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  
}
