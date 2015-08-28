//
//  VideoViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/17.
//  Copyright © 2015年 Eular. All rights reserved.
//

import UIKit
import CoreData

class VideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var vSegmentedControl: UISegmentedControl!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var relatedView: UIView!
    
    var curVideo: VideoModel!
    var commentList: NSArray = []
    let commentCellIdentifier = "commentCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let t1 = commentView.viewWithTag(100) as! UITableView
        t1.delegate = self
        t1.dataSource = self
        webView.loadHTMLString("<style>body{background:black;}</style><body></body>", baseURL: nil)
        webView.scalesPageToFit = true
        webView.scrollView.scrollEnabled = false
        loadCurVideoData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"videoLiked:", name: "LikedNotification", object: nil)
    }
    
    func videoLiked(notification: NSNotification) {
        if saveCurVideoInCoreData("LikedVideo") {
            self.view.makeToast(message: "已收藏", duration: 1, position: "center")
        }
    }

    func getTimestamp() -> String {
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.stringFromDate(now)
        let time = formatter.dateFromString(date)!
        return String(time.timeIntervalSince1970)
    }
    
    func saveCurVideoInCoreData(entityName: String) -> Bool {
        // 1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // 2
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
        let likedVideo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        // 3
        likedVideo.setValue(curVideo.title, forKey: "title")
        likedVideo.setValue(curVideo.src, forKey: "src")
        likedVideo.setValue(curVideo.thumbnail, forKey: "thumbnail")
        likedVideo.setValue(getTimestamp(), forKey: "timestamp")
        
        // 4
        do {
            try managedContext.save()
            return true
        } catch {
            print("Could not save")
            return false
        }
    }
    
    func loadCurVideoData() {
        self.view.makeToastActivityWithMessage(message: "玩命加载中...")
        let url = NSURL(string: "http://urinx.sinaapp.com/vu.json?url=\(curVideo.src)")
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url!), queue: NSOperationQueue()) { (resp: NSURLResponse?, data: NSData?, err: NSError?) -> Void in
            if let vData = data {
                do {
                    let videoJson = try NSJSONSerialization.JSONObjectWithData(vData, options: NSJSONReadingOptions.AllowFragments)
                    let title = videoJson.objectForKey("title") as! String
                    let pubTime = videoJson.objectForKey("pubTime") as! String
                    let category = videoJson.objectForKey("category") as! String
                    let tag = videoJson.objectForKey("tag") as! Array<String>
                    let view = videoJson.objectForKey("view") as! String
                    let src = videoJson.objectForKey("src") as! String
                    self.commentList = videoJson.objectForKey("comment") as! NSArray
                    
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        let titleLB = self.detailView.viewWithTag(1) as! UILabel
                        let timeLB = self.detailView.viewWithTag(2) as! UILabel
                        let categoryLB = self.detailView.viewWithTag(3) as! UILabel
                        let tagLB = self.detailView.viewWithTag(4) as! UILabel
                        let viewLB = self.detailView.viewWithTag(5) as! UILabel
                        titleLB.text = title
                        timeLB.text = pubTime
                        categoryLB.text = category
                        tagLB.text = ",".join(tag)
                        viewLB.text = view
                        self.curVideo.title = title
                        
                        let localRequest = NSURLRequest(URL: NSURL(string: src)!)
                        self.webView.loadRequest(localRequest)
                        let t1 = self.commentView.viewWithTag(100) as! UITableView
                        t1.reloadData()
                        self.view.hideToastActivity()
                    })
                } catch {
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.view.hideToastActivity()
                        self.view.makeToast(message: "加载失败")
                    })
                }
            }
        }
    }

    @IBAction func indexChanged(sender: AnyObject) {
        switch vSegmentedControl.selectedSegmentIndex {
        case 0:
            detailView.hidden = false
            commentView.hidden = true
            relatedView.hidden = true
        case 1:
            detailView.hidden = true
            commentView.hidden = false
            relatedView.hidden = true
        case 2:
            detailView.hidden = true
            commentView.hidden = true
            relatedView.hidden = false
        default:
            break
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(commentCellIdentifier, forIndexPath: indexPath)
        let row = indexPath.row
        
        let nameLB = cell.viewWithTag(2) as! UILabel
        let saidLB = cell.viewWithTag(3) as! UILabel
        let timeLB = cell.viewWithTag(4) as! UILabel
        
        nameLB.text = commentList[row].objectForKey("name") as? String
        saidLB.text = commentList[row].objectForKey("said") as? String
        timeLB.text = commentList[row].objectForKey("time") as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func shareAction(sender: AnyObject) {
        let shareText = NSString(string: curVideo.title)
        let shareUrl = NSURL(string: curVideo.src)!
        let shareImage = UIImage(data: NSData(contentsOfURL: NSURL(string: curVideo.thumbnail)!)!)!
        
        let activityViewController = UIActivityViewController(activityItems: [shareText, shareUrl, shareImage], applicationActivities: [WeiXinActivity(), WeiXinTimelineActivity(), LikedActivity()])
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
