//
//  NewsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit
import MWFeedParser

class NewsTableViewController: UITableViewController, UITextViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, MWFeedParserDelegate {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  var xmlParser: NSXMLParser!
  var entryTitle: String!
  var entryDescription: String!
  var entryLink: String!
  var entryDate: String!
  var currentParsedElement:String! = String()
  var entryDictionary: [String:String]! = Dictionary()
  var entriesArray:[Dictionary<String, String>]! = Array()
  var firstTimeShowed = true
  var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
  var feedParser = MWFeedParser()
  var notificationCenter = NSNotificationCenter.defaultCenter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    notificationCenter.addObserver(self, selector: #selector(NewsTableViewController.freezeView), name: "freezeViews", object: nil)
    menuButton.target = self.revealViewController()
    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    self.title = "Notícias"
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    activityIndicator.center = view.center
    activityIndicator.startAnimating()
    activityIndicator.hidden = false
    view.addSubview(activityIndicator)
    
    DataManager.sharedInstance.allNews = []
    requestRssLink { (result) in
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func freezeView() {
    
    if DataManager.sharedInstance.menuIsOpen {
      self.tableView.allowsSelection = false
      self.tableView.scrollEnabled = false
    } else {
      self.tableView.allowsSelection = true
      self.tableView.scrollEnabled = true
    }
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if firstTimeShowed {
      return 1
    } else {
      return DataManager.sharedInstance.allNews.count + 1
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if firstTimeShowed {
      let cell = UITableViewCell()
      return cell
    } else {
      if indexPath.row <= DataManager.sharedInstance.allStates.count-1 {
        let cell = tableView.dequeueReusableCellWithIdentifier("newCellNew", forIndexPath: indexPath) as! NewTableViewCell
        cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
        cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
        cell.labelTitle.userInteractionEnabled = false
        cell.selectionStyle = .None
        return cell
        
//        if DataManager.sharedInstance.allNews[indexPath.row].type == "Complex" {
//          let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
//          cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
//          cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
//          cell.textDescription.text = DataManager.sharedInstance.allNews[indexPath.row].newDescription
//          cell.imageDescription.image = UIImage(named: DataManager.sharedInstance.allNews[indexPath.row].img)
//          
//          cell.heightTextView.constant = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
//          return cell
//        } else if DataManager.sharedInstance.allNews[indexPath.row].type == "Simple" {
//          let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
//          cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
//          cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
//          cell.textDescription.text = ""
//          let heightTV = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
//          cell.heightTextView.constant = heightTV
//          cell.imageDescription.frame = CGRectMake(0, 0, 0, 0)
//          cell.imageDescription.viewWithTag(0)?.removeFromSuperview()
//          return cell
//        } else {
//          let cell = tableView.dequeueReusableCellWithIdentifier("thirdCell", forIndexPath: indexPath) as! ThirdNewTableViewCell
//          cell.imageDescription.image = UIImage(named: DataManager.sharedInstance.allNews[indexPath.row].img)
//          cell.heightView.constant = cell.imageDescription.frame.height
//          return cell
//        }
      } else {
        let cell = UITableViewCell()
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
        return cell
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let link = DataManager.sharedInstance.allNews[indexPath.row].link
    let linkNew = link.componentsSeparatedByString("\n")
    UIApplication.sharedApplication().openURL(NSURL(string: linkNew.first!)!)
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- IBACTIONS ---
  ///////////////////////////////////////////////////////////
  
  @IBAction func searchButtonTap(sender: AnyObject) {
    DataManager.sharedInstance.instantiateSearch(self.navigationController!)
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- EMPTY TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  func titleForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Sem Notícias"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView) -> NSAttributedString? {
    let str = "Nenhuma notícia para mostrar"
    let attr = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    return NSAttributedString(string: str, attributes: attr)
  }
  
  func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
    return Util.imageResize(UIImage(named: "logo-pretaAbert.png")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    dismissViewControllerAnimated(true) {
    }
  }
  
  func requestRssLink(completion: (result: Bool) -> Void) {
    let requestManager = RequestManager()
    requestManager.requestFeed { (resultFeedLink) in
      if resultFeedLink.count > 0 {
        self.requestRSS((resultFeedLink.first?.link)!, completion: { (resultNew) in
          completion(result: true)
        })
      } else {
        Util.displayAlert(title: "Problemas", message: "Houve algum problema ao fazer o download das notícias, tente novamente mais tarde", action: "Ok")
      }
    }
  }
  
  func requestRSS(url:String,completion: (resultNew: Bool) -> Void) {
    feedParser = MWFeedParser(feedURL: NSURL(string: url))
    feedParser.delegate = self
    feedParser.feedParseType = ParseTypeFull
    feedParser.connectionType = ConnectionTypeSynchronously
    feedParser.parse()
    
    
  }
  
  func feedParserDidStart(parser: MWFeedParser!) {
    DataManager.sharedInstance.allNews = []
  }
  
  func feedParserDidFinish(parser: MWFeedParser!) {
    firstTimeShowed = false
    self.tableView.allowsSelection = true
    self.activityIndicator.hidden = true
    self.activityIndicator.removeFromSuperview()
    tableView.reloadData()
  }
  
  func feedParser(parser: MWFeedParser!, didFailWithError error: NSError!) {
    
  }
  
  func feedParser(parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
    
  }
  
  func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
    let entryDate = item.date
    let entryTitle = item.title
    let entryLink = item.link
    let entryDescription = item.description
    if entryTitle != "[No Title]" && entryLink != "[No Link]" && entryDescription != "[No Description]" && entryDate != "[No Date]"{
      if entryDate.timeIntervalSinceNow < 0 {
        let new = New(title: entryTitle, descr: entryDescription, link: entryLink, date: entryDate)
        DataManager.sharedInstance.allNews.append(new)
      }
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    self.clearsSelectionOnViewWillAppear = true
  }
  
}
