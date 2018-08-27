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
  
  var selectedMode:UserMode = .reviews
  enum UserMode {
    case reviews
    case posts
    case radios
  }
  var colorBlack : UIColor!
  var colorWhite : UIColor!
  var actualUser = UserRealm()
  var viewTitle = ""
  var actualReviews = [Review]()
  var actualPosts = [Comment]()
  var actualRadios = [RadioRealm]()
  var actualArraySegmented = [AnyObject]()
  
  var existFollowers = false
  var existFollowing = false
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //self.title = viewTitle
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.isHidden = true
    let components = DataManager.sharedInstance.interfaceColor.color.cgColor.components
    colorBlack = DataManager.sharedInstance.interfaceColor.color
    colorWhite =  ColorRealm(name: 45, red: (components?[0])!+0.1, green: (components?[1])!+0.1, blue: (components?[2])!+0.1, alpha: 1).color
    self.clearsSelectionOnViewWillAppear = true
    tableView.estimatedRowHeight = 40
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.register(UINib(nibName: "CellDesign",bundle:nil), forCellReuseIdentifier: "baseCell")
    let requestFollowers = RequestManager()
    let requestFollowing = RequestManager()
    let requestReviews = RequestManager()
    
    defineBarButton()
    
    requestFollowers.requestNumberOfFollowers(actualUser) { (resultNumberFollowers) in
      requestFollowing.requestNumberOfFollowing(self.actualUser, completion: { (resultNumberFollowing) in
        let detailCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DetailUserTableViewCell
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
      self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if section == 0 {
      return 2
    } else {
      if selectedMode == .reviews {
        if actualReviews.count != 0 {
          return actualReviews.count + 1
        } else {
          return 1
        }
      } else if selectedMode == .posts {
        if actualPosts.count != 0 {
          return actualPosts.count + 1
        } else {
          return 1
        }
      } else if selectedMode == .radios {
        if actualRadios.count != 0 {
          return actualRadios.count + 1
        } else {
          return 1
        }
      }
    }
    return 0
  }
  
  @IBAction func segmentControlChanged(_ sender: AnyObject) {
    view.addSubview(activityIndicator)
    activityIndicator.isHidden = false
    tableView.allowsSelection = false
    let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SegmentedTableViewCell
    if cell.segmentedControl.selectedSegmentIndex == 0 {
      selectedMode = .reviews
      let requestReviews = RequestManager()
      requestReviews.requestReviewsOfUser(actualUser, pageSize: 10, pageNumber: 0) { (resultReview) in
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        self.actualReviews = resultReview
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
      }
    } else if cell.segmentedControl.selectedSegmentIndex == 1 {
      selectedMode = .posts
      let requestPosts = RequestManager()
      requestPosts.requestWallOfUser(actualUser, pageNumber: 0, pageSize: 10, completion: { (resultWall) in
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        self.actualPosts = resultWall
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
      })
    } else if cell.segmentedControl.selectedSegmentIndex == 2 {
      selectedMode = .radios
      let requestPosts = RequestManager()
      requestPosts.requestRadiosOfUser(actualUser, pageNumber: 0, pageSize: 10, completion: { (resultWall) in
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        self.actualRadios = resultWall
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
      })
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    switch indexPath.section {
    case 0:
      if indexPath.row == 0 {
        let detailCell = tableView.dequeueReusableCell(withIdentifier: "detailUser", for: indexPath) as! DetailUserTableViewCell
        if actualUser.userImage == "avatar.png" {
          detailCell.imageUser.image = UIImage(named: "avatar.png")
        } else {
          detailCell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualUser.userImage)))
        }
        detailCell.imageUser.layer.cornerRadius = detailCell.imageUser.bounds.height / 6
        detailCell.imageUser.layer.borderColor = DataManager.sharedInstance.interfaceColor.color.cgColor
        detailCell.imageUser.layer.backgroundColor = UIColor.white.cgColor
        detailCell.imageUser.layer.borderWidth = 0
        detailCell.imageUser.clipsToBounds = true
        detailCell.labelLocal.text = actualUser.shortAddress.uppercased()
        detailCell.labelLocal.textColor = UIColor.white
        detailCell.backgroundColor = UIColor(gradientStyle: .topToBottom, withFrame: detailCell.frame, andColors: [colorWhite,colorBlack])
        detailCell.labelName.text = actualUser.name.uppercased()
        detailCell.labelName.textColor = UIColor.white
        detailCell.labelFollowing.textColor = UIColor.white
        detailCell.labelFollowers.textColor = UIColor.white
        detailCell.labelIndicatorFollowers.textColor = UIColor.white
        detailCell.labelIndicatorFollowing.textColor = UIColor.white
        detailCell.labelIndicatorFollowing.text = "Seguindo"
        detailCell.labelIndicatorFollowers.text = "Seguidores"
        detailCell.selectionStyle = .none
        detailCell.buttonFollowers.backgroundColor = UIColor.clear
        detailCell.buttonFollowing.backgroundColor = UIColor.clear
        detailCell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
        detailCell.labelFollowers.text = "-"
        detailCell.labelFollowing.text = "-"
        return detailCell
      } else if indexPath.row == 1 {
        let segmentedCell = tableView.dequeueReusableCell(withIdentifier: "segmentedCell", for: indexPath) as! SegmentedTableViewCell
        segmentedCell.backgroundColor = colorBlack
        segmentedCell.segmentedControl.tintColor = UIColor.white
        segmentedCell.segmentedControl.backgroundColor = UIColor.clear
        segmentedCell.selectionStyle = .none
        segmentedCell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0)
        return segmentedCell
      }
    case 1:
      if selectedMode == .posts {
        if actualPosts.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "noPostsCell", for: indexPath) as! NoPostsTableViewCell
          cell.labelTitle.text = "Nenhuma publicação realizada"
          cell.textViewDescription.text = "\(actualUser.name) não realizou nenhuma publicação até o momento"
          cell.selectionStyle = .none
          return cell
        } else {
          if indexPath.row <= actualPosts.count-1 {
            if actualPosts[indexPath.row].postType == .audio {
              let cell = tableView.dequeueReusableCell(withIdentifier: "wallAudioCell", for: indexPath) as! WallAudioPlayerTableViewCell
              cell.labelName.text = actualPosts[indexPath.row].user.name
              cell.labelDate.text = Util.getOverdueInterval(actualPosts[indexPath.row].date)
              cell.textViewWall.text = actualPosts[indexPath.row].text
              if actualPosts[indexPath.row].user.userImage == "avatar.png" {
                cell.imageUser.image = UIImage(named: "avatar.png")
              } else {
                
                cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualPosts[indexPath.row].radio.thumbnail)))
              }
              cell.identifier = actualPosts[indexPath.row].audio
              return cell
              
            }
            if actualPosts[indexPath.row].postType == .image {
              let cell = tableView.dequeueReusableCell(withIdentifier: "wallImageCell", for: indexPath) as! WallImageTableViewCell
              cell.labelName.text = actualPosts[indexPath.row].user.name
              cell.labelDate.text = Util.getOverdueInterval(actualPosts[indexPath.row].date)
              cell.textViewWall.text = actualPosts[indexPath.row].text
              if actualPosts[indexPath.row].user.userImage == "avatar.png" {
                cell.imageUser.image = UIImage(named: "avatar.png")
              } else {
                cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualPosts[indexPath.row].radio.thumbnail)))
              }
              cell.buttonZoomImage.tag = indexPath.row
              cell.tag = indexPath.row
                cell.imageAttachment.kf.indicatorType = .activity
              if !cell.isReloadCell {
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                  cell.imageAttachment?.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualPosts[indexPath.row].image)), placeholder: UIImage(), options: [.transition(.fade(0.2))], progressBlock: { (receivedSize, totalSize) in
                    
                    }, completionHandler: { (image, error, cacheType, imageURL) in
                      
                      DispatchQueue.main.async(execute: {

                        if self.selectedMode == .posts {
                          if let image3 = image {
                            if let image2 = image3 as? UIImage {
                              if cell.tag == indexPath.row && !cell.isReloadCell{
                                let ratio = (image2.size.height)/(image2.size.width)
                                
                                cell.imageAttachment.frame = CGRect(x: cell.imageAttachment.frame.origin.x, y: cell.imageAttachment.frame.origin.y, width: cell.frame.width, height: ratio*cell.frame.width)
                                cell.heightImage.constant = ratio*cell.frame.width
                                cell.widthImage.constant = cell.frame.width
                                //cell.imageAttachment.image = image
                                tableView.beginUpdates()
                                tableView.reloadRows(at: [indexPath], with: .automatic)
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
              cell.buttonZoomImage.backgroundColor = UIColor.clear
              return cell
            } else {
              let cell = tableView.dequeueReusableCell(withIdentifier: "wallCell", for: indexPath) as! WallTableViewCell
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
                cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualPosts[indexPath.row].radio.thumbnail)))
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
      } else if selectedMode == .reviews {
        if actualReviews.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "noPostsCell", for: indexPath) as! NoPostsTableViewCell
          cell.labelTitle.text = "Nenhuma avaliação realizada"
          cell.textViewDescription.text = "\(actualUser.name) não realizou nenhuma avaliação até o momento"
          cell.selectionStyle = .none
          return cell
        } else {
          if indexPath.row <= actualReviews.count-1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
            cell.labelName.text = actualReviews[indexPath.row].user.name
            cell.labelDate.text = Util.getOverdueInterval(actualReviews[indexPath.row].date)
            cell.textViewReview.text = actualReviews[indexPath.row].text
            if actualReviews[indexPath.row].user.userImage == "avatar.png" {
              cell.imageUser.image = UIImage(named: "avatar.png")
            } else {
              
              cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualReviews[indexPath.row].radio.thumbnail)))
            }
            if actualReviews[indexPath.row].score != 0 && actualReviews[indexPath.row].score != -1 {
              for index in 0...actualReviews[indexPath.row].score-1 {
                cell.stars[index].image = UIImage(named: "star.png")
                cell.stars[index].tintColor = UIColor.red
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
      } else if selectedMode == .radios {
        if actualRadios.count == 0 {
          let cell = tableView.dequeueReusableCell(withIdentifier: "noPostsCell", for: indexPath) as! NoPostsTableViewCell
          cell.labelTitle.text = "Nenhuma rádio favoritada"
          cell.textViewDescription.text = "\(actualUser.name) não favoritou nenhuma rádio até o momento"
          cell.selectionStyle = .none
          return cell
        } else {
          if indexPath.row <= actualRadios.count-1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath) as! InitialTableViewCell
            cell.labelName.text = actualRadios[indexPath.row].name
            cell.labelLocal.text = actualRadios[indexPath.row].address.formattedLocal
            cell.imageBig.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadios[indexPath.row].thumbnail)))
            if actualRadios[indexPath.row].isFavorite {
              cell.imageSmallOne.image = UIImage(named: "heartRed.png")
            } else {
              cell.imageSmallOne.image = UIImage(named: "heart.png")
            }
            cell.labelDescriptionOne.text = "\(actualRadios[indexPath.row].likenumber)"
            cell.imageSmallTwo.image = UIImage(contentsOfFile: "")
            cell.labelDescriptionTwo.text = ""
            return cell
          } else {
            let cell = UITableViewCell()
            cell.tag = 1000
            cell.selectionStyle = .none
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tableView.cellForRow(at: indexPath)?.tag != 1000 {
      if indexPath.section == 1 {
        if selectedMode == .posts {
          DataManager.sharedInstance.instantiateSubCommentView(self.navigationController!, comment: actualPosts[indexPath.row])
        } else if selectedMode == .reviews {
          DataManager.sharedInstance.instantiateRadioDetailView(self.navigationController!, radio: actualReviews[indexPath.row].radio)
        } else if selectedMode == .radios {
          DataManager.sharedInstance.instantiateRadioDetailView(self.navigationController!, radio: actualRadios[indexPath.row])
        }
      }
    }
  }
  
  @IBAction func buttonFollowersTap(_ sender: AnyObject) {
    if existFollowers {
      view.addSubview(activityIndicator)
      activityIndicator.isHidden = false
      tableView.allowsSelection = false
      let requestFollowers = RequestManager()
      requestFollowers.requestFollowers(actualUser, pageSize: 20, pageNumber: 0) { (resultFollowers) in
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowers, title: "Seguidores de \(self.actualUser.name)")
      }
    }
    
  }
  
  @IBAction func buttonFollowingTap(_ sender: AnyObject) {
    if existFollowing {
      view.addSubview(activityIndicator)
      activityIndicator.isHidden = false
      tableView.allowsSelection = false
      let requestFollowing = RequestManager()
      requestFollowing.requestFollowing(actualUser, pageSize: 20, pageNumber: 0) { (resultFollowing) in
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        DataManager.sharedInstance.instantiateListOfUsers(self.navigationController!, userList: resultFollowing, title: "Seguindo \(self.actualUser.name)")
      }
    }
  }
  
  func defineBarButton() {
    if !actualUser.isFollowing {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-add.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
    } else {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-remove.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
    }
  }
  
  func buttonFollowTap() {
    if DataManager.sharedInstance.isLogged {
      let manager = RequestManager()
      if !actualUser.isFollowing {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-remove.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
        actualUser.updateFollowing(true)
        manager.followUser(actualUser, completion: { (follow) in
          if !follow {
            Util.displayAlert(title: "Atenção", message: "Não foi possivel seguir o usuário \(self.actualUser.name). Contate o administrador da aplicação", action: "Ok")
          } else {
            Util.displayAlert(title: "Atenção", message: "Você está seguindo \(self.actualUser.name) agora" , action: "Ok")
          }
        })
      } else {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "user-add.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(UserDetailTableViewController.buttonFollowTap))
        actualUser.updateFollowing(false)
        manager.unfollowUser(actualUser, completion: { (follow) in
          if !follow {
            Util.displayAlert(title: "Atenção", message: "Não foi possivel parar de seguir o usuário \(self.actualUser.name). Contate o administrador da aplicação", action: "Ok")
          } else {
            Util.displayAlert(title: "Atenção", message: "Você não está mais seguindo \(self.actualUser.name)" , action: "Ok")
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
