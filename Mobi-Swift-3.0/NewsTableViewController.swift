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
    var xmlParser: XMLParser!
    var entryTitle: String!
    var entryDescription: String!
    var entryLink: String!
    var entryDate: String!
    var currentParsedElement:String! = String()
    var entryDictionary: [String:String]! = Dictionary()
    var entriesArray:[Dictionary<String, String>]! = Array()
    var firstTimeShowed = true
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var feedParser = MWFeedParser()
    var rss = RSS()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///////////////////////////////////////////////////////////
        //MARK: --- BASIC CONFIG ---
        ///////////////////////////////////////////////////////////
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        self.title = "Notícias \(rss.desc)"
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        view.addSubview(activityIndicator)
        DataManager.sharedInstance.allNews = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    ///////////////////////////////////////////////////////////
    //MARK: --- TABLE VIEW DELEGATE ---
    ///////////////////////////////////////////////////////////
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if firstTimeShowed {
            return 1
        } else {
            return DataManager.sharedInstance.allNews.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if firstTimeShowed {
            let cell = UITableViewCell()
            return cell
        } else {
            if indexPath.row <= DataManager.sharedInstance.allNews.count-1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newCellNew", for: indexPath) as! NewTableViewCell
                cell.labelDate.text = DataManager.sharedInstance.allNews[indexPath.row].date
                cell.labelTitle.text = DataManager.sharedInstance.allNews[indexPath.row].title
                cell.labelTitle.isUserInteractionEnabled = false
                cell.selectionStyle = .none
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
                return cell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let link = DataManager.sharedInstance.allNews[indexPath.row].link
        let linkNew = link.components(separatedBy: "\n")
        UIApplication.shared.openURL(URL(string: linkNew.first!)!)
    }
    
    ///////////////////////////////////////////////////////////
    //MARK: --- IBACTIONS ---
    ///////////////////////////////////////////////////////////
    
    
    
    ///////////////////////////////////////////////////////////
    //MARK: --- EMPTY TABLE VIEW DELEGATE ---
    ///////////////////////////////////////////////////////////
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Sem Notícias"
        let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attr)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Nenhuma notícia para mostrar"
        let attr = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attr)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return Util.imageResize(UIImage(named: "logo-pretaAbert.png")!, sizeChange: CGSize(width: 100, height: 100))
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView) {
        dismiss(animated: true) {
        }
    }
    
    func requestRssLink(_ completion: @escaping (_ result: Bool) -> Void) {
        self.requestRSS((rss.link), completion: { (resultNew) in
            completion(true)
        })
        //    let requestManager = RequestManager()
        //    requestManager.requestFeed { (resultFeedLink) in
        //      if resultFeedLink.count > 0 {
        //
        //      } else {
        //        Util.displayAlert(title: "Problemas", message: "Houve algum problema ao fazer o download das notícias, tente novamente mais tarde", action: "Ok")
        //      }
        //    }
    }
    
    func requestRSS(_ url:String,completion: (_ resultNew: Bool) -> Void) {
        feedParser = MWFeedParser(feedURL: URL(string: url))
        feedParser.delegate = self
        feedParser.feedParseType = ParseTypeFull
        feedParser.connectionType = ConnectionTypeSynchronously
        feedParser.parse()
        
        
    }
    
    func feedParserDidStart(_ parser: MWFeedParser!) {
        DataManager.sharedInstance.allNews = []
    }
    
    func feedParserDidFinish(_ parser: MWFeedParser!) {
        firstTimeShowed = false
        self.tableView.allowsSelection = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.removeFromSuperview()
        tableView.reloadData()
    }
    
    func feedParser(_ parser: MWFeedParser!, didFailWithError error: NSError!) {
        
    }
    
    func feedParser(_ parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        
    }
    
    func feedParser(_ parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        let entryDate = item.date
        let entryTitle = item.title
        let entryLink = item.link
        let entryDescription = item.description
        if let _ = entryDate {
            if entryTitle != "[No Title]" && entryLink != "[No Link]" && entryDescription != "[No Description]"  && entryTitle != "" && entryLink != "" {
                if (entryDate?.timeIntervalSinceNow)! < TimeInterval(0.0) {
                    let new = New(title: entryTitle!, descr: entryDescription, link: entryLink!, date: entryDate!)
                    DataManager.sharedInstance.allNews.append(new)
                }
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = true
        requestRssLink { (result) in
        }
    }
    
}
