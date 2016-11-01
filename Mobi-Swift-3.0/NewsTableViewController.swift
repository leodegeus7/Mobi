//
//  NewsTableViewController.swift
//  Mobi-Swift-3.0
//
//  Created by Desenvolvimento Access Mobile on 8/9/16.
//  Copyright © 2016 Access Mobile. All rights reserved.
//  Criado por Leonardo de Geus // linkedin.com/leodegeus

import UIKit


class NewsTableViewController: UITableViewController, UITextViewDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, NSXMLParserDelegate {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  var xmlParser: NSXMLParser!
  var entryTitle: String!
  var entryDescription: String!
  var entryLink: String!
  var currentParsedElement:String! = String()
  var entryDictionary: [String:String]! = Dictionary()
  var entriesArray:[Dictionary<String, String>]! = Array()
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    ///////////////////////////////////////////////////////////
    //MARK: --- BASIC CONFIG ---
    ///////////////////////////////////////////////////////////
    
    menuButton.target = self.revealViewController()
    menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 400
    self.title = "Notícias"
    tableView.emptyDataSetSource = self
    tableView.emptyDataSetDelegate = self
    tableView.tableFooterView = UIView()
    
    DataManager.sharedInstance.allNews = []
    requestRssLink()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  ///////////////////////////////////////////////////////////
  //MARK: --- TABLE VIEW DELEGATE ---
  ///////////////////////////////////////////////////////////
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return DataManager.sharedInstance.allNews.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if DataManager.sharedInstance.allNews[indexPath.row].type == "Complex" {
      let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
      cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
      cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
      cell.textDescription.text = DataManager.sharedInstance.allNews[indexPath.row].newDescription
      cell.imageDescription.image = UIImage(named: DataManager.sharedInstance.allNews[indexPath.row].img)
      
      cell.heightTextView.constant = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
      return cell
    } else if DataManager.sharedInstance.allNews[indexPath.row].type == "Simple" {
      let cell = tableView.dequeueReusableCellWithIdentifier("firstCell", forIndexPath: indexPath) as! FirstNewTableViewCell
      cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
      cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
      cell.textDescription.text = ""
      let heightTV = cell.textDescription.sizeThatFits(cell.textDescription.bounds.size).height as CGFloat
      cell.heightTextView.constant = heightTV
      cell.imageDescription.frame = CGRectMake(0, 0, 0, 0)
      cell.imageDescription.viewWithTag(0)?.removeFromSuperview()
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier("thirdCell", forIndexPath: indexPath) as! ThirdNewTableViewCell
      cell.imageDescription.image = UIImage(named: DataManager.sharedInstance.allNews[indexPath.row].img)
      cell.heightView.constant = cell.imageDescription.frame.height
      return cell
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
    return Util.imageResize(UIImage(named: "happy.jpg")!, sizeChange: CGSize(width: 100, height: 100))
  }
  
  func emptyDataSetDidTapButton(scrollView: UIScrollView) {
    dismissViewControllerAnimated(true) {
    }
  }
  
  func requestRssLink() {
    let requestManager = RequestManager()
    requestManager.requestFeed { (resultFeedLink) in
      if resultFeedLink.count > 0 {
        self.requestRSS((resultFeedLink.first?.link)!)
      } else {
        Util.displayAlert(title: "Problemas", message: "Houve algum problema ao fazer o download das notícias, tente novamente mais tarde", action: "Ok")
      }
    }
  }
  
  func requestRSS(url:String) {
    let rssUrlRequest:NSURLRequest = NSURLRequest(URL:NSURL(string: url)!)
    let queue:NSOperationQueue = NSOperationQueue()
    NSURLConnection.sendAsynchronousRequest(rssUrlRequest, queue: queue) { (response, data, error) in
      
      self.xmlParser = NSXMLParser(data: data!)
      self.xmlParser.delegate = self
      self.xmlParser.shouldProcessNamespaces = false
      self.xmlParser.shouldResolveExternalEntities = false
      self.xmlParser.shouldReportNamespacePrefixes = false
      self.xmlParser.parse()
    }
  }
  
  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    if elementName == "title"{
      entryTitle = String()
      currentParsedElement = "title"
    }
    if elementName == "description"{
      entryDescription = String()
      currentParsedElement = "description"
    }
    if elementName == "link"{
      entryLink = String()
      currentParsedElement = "link"
    }
  }
  
  func parser(parser: NSXMLParser,
              foundCharacters string: String){
    if currentParsedElement == "title"{
      entryTitle = entryTitle + string
    }
    if currentParsedElement == "description"{
      entryDescription = entryDescription + string
    }
    if currentParsedElement == "link"{
      entryLink = entryLink + string
    }
  }
  
  func parser(parser: NSXMLParser,
              didEndElement elementName: String,
                            namespaceURI: String?,
                            qualifiedName qName: String?){
    
    if elementName == "title"{
      entryDictionary["title"] = entryTitle
    }
    if elementName == "link"{
      entryDictionary["link"] = entryLink
    }
    if elementName == "description"{
      entryDictionary["description"] = entryDescription
      if entryTitle != nil && entryTitle != "" && entryLink != nil && entryLink != "" && entryDescription != nil && entryDescription != "" {
        let new = New(title: entryTitle , descr: entryDescription,link:entryLink)
        DataManager.sharedInstance.allNews.append(new)
      }
      entriesArray.append(entryDictionary)
    }
    
  }
  
  func parserDidEndDocument(parser: NSXMLParser){
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  
  
  
}
