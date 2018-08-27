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
  
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
  
  var firstTimeToShow = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Comentários"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: Util.imageResize(UIImage(named: "plus.png")!, sizeChange: CGSize(width: 20, height: 20)), style: UIBarButtonItemStyle.done, target: self, action: #selector(RadioTableViewController.createComment))
    let requestManager = RequestManager()
    requestManager.requestComments(actualComment, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
      self.actualSubComments = resultWall
      self.tableView.allowsSelection = true
      self.activityIndicator.isHidden = true
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
  
  override func viewWillAppear(_ animated: Bool) {
    firstTimeToShow = true
    self.tableView.reloadData()
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    activityIndicator.isHidden = false
    tableView.allowsSelection = false
    self.clearsSelectionOnViewWillAppear = true
    let requestManager = RequestManager()
    requestManager.requestComments(actualComment, pageNumber: 0, pageSize: 20, completion: { (resultWall) in
      self.actualSubComments = resultWall
      self.tableView.allowsSelection = true
      self.activityIndicator.isHidden = true
      self.self.activityIndicator.removeFromSuperview()
      self.tableView.reloadData()
    })
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
  
  func createComment() {
    if DataManager.sharedInstance.isLogged {
      performSegue(withIdentifier: "createPublicacionSegue", sender: self)
    } else {
      func okAction() {
        DataManager.sharedInstance.instantiateProfile(self.navigationController!)
      }
      func cancelAction() {
      }
      self.displayAlert(title: "Atenção", message: "Para utilizar este recurso é necessário efetuar login. Deseja fazer isso agora?", okTitle: "Logar", cancelTitle: "Cancelar", okAction: okAction, cancelAction: cancelAction)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let ident = (segue.identifier)!
    if ident == "createPublicacionSegue" {
      let createVC = (segue.destination as! SendPublicationViewController)
      createVC.actualMode = .comment
      createVC.actualComment = actualComment
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if firstTimeToShow {
      let cell = UITableViewCell()
      firstTimeToShow = false
      return cell
    }
    else {
      if indexPath.section == 0 {
        if actualComment.postType == .audio {
          let cell = tableView.dequeueReusableCell(withIdentifier: "wallAudioCell", for: indexPath) as! WallAudioPlayerTableViewCell
          cell.labelName.text = actualComment.user.name
          cell.selectionStyle = .none
          cell.labelDate.text = Util.getOverdueInterval(actualComment.date)
          cell.textViewWall.text = actualComment.text
          if actualComment.user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComment.user.userImage)))
          }
          cell.identifier = actualComment.audio
          return cell
          
        }
        if actualComment.postType == .image {
          let cell = tableView.dequeueReusableCell(withIdentifier: "wallImageCell", for: indexPath) as! WallImageTableViewCell
          cell.selectionStyle = .none
          cell.labelName.text = actualComment.user.name
          cell.labelDate.text = Util.getOverdueInterval(actualComment.date)
          cell.textViewWall.text = actualComment.text
          if actualComment.user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComment.user.userImage)))
          }
          cell.buttonZoomImage.tag = indexPath.row
          cell.tag = indexPath.row
            cell.imageAttachment.kf.indicatorType = .activity
          if !cell.isReloadCell {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
              cell.imageAttachment?.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(self.actualComment.image)), placeholder: UIImage(), options: [.transition(.fade(0.2))], progressBlock: { (receivedSize, totalSize) in
                
                }, completionHandler: { (image, error, cacheType, imageURL) in
                  
                  DispatchQueue.main.async(execute: {
                    
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
                    
                  })
              })
            })
          }
          cell.buttonZoomImage.backgroundColor = UIColor.clear
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "wallCell", for: indexPath) as! WallTableViewCell
          cell.selectionStyle = .none
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
            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualComment.user.userImage)))
          }
          return cell
        }
      } else if indexPath.section == 1 {
        if let _ = actualSubComments {
          if actualSubComments.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noPostsCell", for: indexPath) as! NoPostsTableViewCell
            cell.labelTitle.text = "Nenhum comentário realizada"
            cell.textViewDescription.text = "Não há nenhum comentário nesta publicação, clique no + a cima para criar"
            cell.selectionStyle = .none
            return cell
          }
        }
        if let _ = actualSubComments  {
          let cell = tableView.dequeueReusableCell(withIdentifier: "wallCell", for: indexPath) as! WallTableViewCell
          cell.labelName.text = actualSubComments[indexPath.row].user.name
          cell.labelDate.text = Util.getOverdueInterval(actualSubComments[indexPath.row].date)
          cell.textViewWall.text = actualSubComments[indexPath.row].text
          if actualSubComments[indexPath.row].user.userImage == "avatar.png" {
            cell.imageUser.image = UIImage(named: "avatar.png")
          } else {
            cell.imageUser.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualSubComments[indexPath.row].user.userImage)))
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
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Postagem atual"
    } else {
      return "Comentários sobre a postagem"
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTYDATA DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    
    let str = "Nenhuma comentario na publicação"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
    var str = ""
    str = "Clique aqui para comentar no comentário"
    let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    imageView.kf.setImage(with:URL(string: RequestManager.getLinkFromImageWithIdentifierString(actualRadio.thumbnail)))
    return Util.imageResize(imageView.image!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
    performSegue(withIdentifier: "createPublicationSegue", sender: self)
  }
  
}
