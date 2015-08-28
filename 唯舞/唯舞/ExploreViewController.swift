//
//  ExploreViewController.swift
//  唯舞
//
//  Created by Eular on 8/27/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit
import CoreData

class ExploreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var exploerTable: UITableView!
    let exploreVideoCellIdentifier = "exploreVideoCell"
    let refreshControl = UIRefreshControl()
    var exploreVideoList = [NSManagedObject]()
    var curVideo: VideoModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        exploerTable.dataSource = self
        exploerTable.delegate = self
        
        // get user info
        let info = NSUserDefaults.standardUserDefaults().objectForKey("userInfo")!
        let nickname = info["nickname"] as! String
        let headimgurl = info["headimgurl"] as! String
        
        // just for test when is not login
        //let nickname = "Ai"
        //let headimgurl = "http://cn.bing.com/th?id=OIP.Mf63ee8ef5232cc5ed1e9deda4dae2222o0&w=103&h=103&c=7&rs=1&qlt=90&pid=3.1&rm=2"
        
        // set table header
        let headerView = UIView()
        let bgImgView = UIImageView()
        let headImgView = UIImageView()
        let nameLabel = UILabel()
        
        let headerWidth = self.view.bounds.size.width
        let headerHeight = headerWidth - 30
        let imgOffset = CGFloat(-60)
        let headImgWidth = CGFloat(70)
        let labelWidth = headerWidth - headImgWidth - 25
        let labelHeight = CGFloat(30)
        
        headerView.frame = CGRectMake(0, 0, headerWidth, headerHeight)
        headerView.backgroundColor = UIColor.whiteColor()
        bgImgView.frame = CGRectMake(0, imgOffset, headerWidth, headerWidth)
        bgImgView.image = UIImage(named: "exploreHeaderBg")
        headerView.addSubview(bgImgView)
        headImgView.frame = CGRectMake(headerWidth - headImgWidth - 10, headerHeight - headImgWidth - 10, headImgWidth, headImgWidth)
        headImgView.layer.borderWidth = 0.5
        headImgView.imageFromUrl(headimgurl)
        headerView.addSubview(headImgView)
        nameLabel.frame = CGRectMake(0, headerHeight - labelHeight - 35, labelWidth, labelHeight)
        nameLabel.text = nickname
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.textAlignment = .Right
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 19)
        headerView.addSubview(nameLabel)
        
        exploerTable.tableHeaderView = headerView
        
        // set autolayout cell
        exploerTable.estimatedRowHeight = 216
        exploerTable.rowHeight = UITableViewAutomaticDimension
        
        // add pull-to-refresh
        refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        exploerTable.addSubview(refreshControl)
        
        // load data
        exploreVideoList = fetchResultInCoreData("Explore")!
        if exploreVideoList.count == 0 {
            updateCoreData("Explore")
        }
    }
    
    func refreshData() {
        updateCoreData("Explore")
    }
    
    func fetchResultInCoreData(entityName: String) -> [NSManagedObject]? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entityName)
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            return fetchedResults?.reverse()
        } catch {}
        return nil
    }

    func updateCoreData(entityName: String) {
        let url = NSURL(string: VuAllDataApi)
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url!), queue: NSOperationQueue()) { (resp: NSURLResponse?, data: NSData?, err: NSError?) -> Void in
            if let vData = data {
                do {
                    let vuJson = try NSJSONSerialization.JSONObjectWithData(vData, options: NSJSONReadingOptions.AllowFragments)
                    let newList = vuJson.objectForKey("new") as! NSArray
                    var check = true
                    for i in newList.reverse() {
                        let d = i as! NSDictionary
                        let md5 = (d["src"] as! String).md5
                        if check {
                            if !isInCoreData(entityName, format: "md5= '\(md5)'") {
                                check = false
                                saveInCoreData(entityName, dict: d, md5: md5)
                            }
                        } else {
                            saveInCoreData(entityName, dict: d, md5: md5)
                        }
                    }
                    if !check {
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            self.exploreVideoList = self.fetchResultInCoreData("Explore")!
                            self.exploerTable.reloadData()
                        })
                    }
                } catch {
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.view.makeToast(message: "加载失败")
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.refreshControl.endRefreshing()
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if exploreVideoList.count == 0 {
            return 1
        } else {
            return exploreVideoList.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(exploreVideoCellIdentifier, forIndexPath: indexPath)
        if exploreVideoList.count != 0 {
            let row = indexPath.row
            let video = exploreVideoList[row]

            let thumbnailUI = cell.viewWithTag(2) as! UIImageView
            let titleUI = cell.viewWithTag(4) as! UILabel
            let timeUI = cell.viewWithTag(5) as! UILabel
        
            thumbnailUI.imageFromUrl(video.valueForKey("thumbnail") as! String)
            titleUI.text = video.valueForKey("title") as? String
            timeUI.text = video.valueForKey("time") as? String
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if exploreVideoList.count != 0 {
            let video = exploreVideoList[indexPath.row]
            let src = video.valueForKey("src") as! String
            let thumbnail = video.valueForKey("thumbnail") as! String
            if src.has("/routines/") || src.has("/battles/") {
                // ...
            } else {
                curVideo = VideoModel(title: "", src: src, thumbnail: thumbnail, views: "", comments: "", time: "")
                self.performSegueWithIdentifier("jumpToVideo", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! VideoViewController
        vc.curVideo = curVideo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
