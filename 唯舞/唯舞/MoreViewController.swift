//
//  MoreViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/17.
//  Copyright © 2015年 Eular. All rights reserved.
//

import UIKit

var videoList = [VideoModel]()

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    let videoCellIdentifier = "videoCell"
    let videoSegueIdentifier = "jumpToVideo"
    let refreshControl = UIRefreshControl()
    let loadMoreLabel = UILabel()
    let tableFooterView = UIView()
    var curVideo: VideoModel!
    var reload: Bool = false
    var tag = ""
    var page = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        // 添加下拉刷新
        refreshControl.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        // refreshControl.attributedTitle = NSAttributedString(string: "松手刷新")
        refreshControl.tintColor = UIColor.whiteColor()
        tableView.addSubview(refreshControl)
        
        if reload || videoList.isEmpty {
            if tag == "all" {
                tag = ""
            }
            videoList.removeAll()
            loadVideoListData(tag)
        } else {
            addDownDragFresh()
        }
        
    }
    
    func loadVideoListData(tag: String, numberOfPage n: Int = 1) {
        let url = NSURL(string: "http://urinx.sinaapp.com/vu.json?tag=\(tag)&page=\(n)")
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url!), queue: NSOperationQueue()) { (resp: NSURLResponse?, data: NSData?, err: NSError?) -> Void in
            if let vData = data {
                do {
                    let vuJson = try NSJSONSerialization.JSONObjectWithData(vData, options: NSJSONReadingOptions.AllowFragments)
                    let newList = vuJson.objectForKey("new")!
                    for i in newList as! NSArray {
                        let title = i.objectForKey("title") as! String
                        let src = i.objectForKey("src") as! String
                        let thumbnail = i.objectForKey("thumbnail") as! String
                        let views = i.objectForKey("views") as! String
                        let comments = i.objectForKey("comments") as! String
                        let time = i.objectForKey("time") as! String
                        videoList.append(VideoModel(title: title, src: src, thumbnail: thumbnail, views: views, comments: comments, time: time))
                    }
                } catch {
                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                        self.view.makeToast(message: "加载失败")
                    })
                }
                dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.addDownDragFresh()
                })
            }
        }
    }
    
    // 添加上拉加载
    func addDownDragFresh() {
        if videoList.count > 26 {
            loadMoreLabel.frame = CGRectMake(0, 0, tableView.bounds.size.width, 30)
            loadMoreLabel.text = "上拉查看更多"
            loadMoreLabel.textAlignment = NSTextAlignment.Center
            loadMoreLabel.textColor = UIColor.whiteColor()
            loadMoreLabel.font = UIFont(name: loadMoreLabel.font.fontName, size: 13)
            tableFooterView.frame = CGRectMake(0, 0, tableView.bounds.size.width, 30)
            tableFooterView.addSubview(loadMoreLabel)
            tableView.tableFooterView = tableFooterView
        }
    }
    
    // 下拉刷新方法
    func refreshData() {
        videoList.removeAll()
        loadVideoListData(tag)
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier, forIndexPath: indexPath)
        let row = indexPath.row
        let video = videoList[row]
        
        let imgUI = cell.viewWithTag(1) as! UIImageView
        let titleUI = cell.viewWithTag(2) as! UILabel
        let viewUI = cell.viewWithTag(3) as! UILabel
        let commentUI = cell.viewWithTag(4) as! UILabel
        
        imgUI.imageFromUrl(video.thumbnail)
        titleUI.text = video.title
        viewUI.text = video.views
        commentUI.text = video.comments
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let video = videoList[indexPath.row]
        let src = video.src
        if src.hasOne(pathArr) {
            // ...
        } else {
            curVideo = video
            self.performSegueWithIdentifier(videoSegueIdentifier, sender: self)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > ( scrollView.contentSize.height - scrollView.frame.size.height + 30 ) {
            loadMoreLabel.text = "载入..."
        } else {
            loadMoreLabel.text = "上拉查看更多"
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if videoList.count > 26 && scrollView.contentOffset.y > ( scrollView.contentSize.height - scrollView.frame.size.height + 30 ) {
            page++
            loadVideoListData(tag, numberOfPage: page)
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == videoSegueIdentifier {
            let vc = segue.destinationViewController as! VideoViewController
            vc.curVideo = curVideo
        }
    }

}
