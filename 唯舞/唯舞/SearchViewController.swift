//
//  SecondViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/15.
//  Copyright © 2015年 Eular. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate {

    @IBOutlet weak var searchBox: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    let videoSegueIdentifier = "jumpToVideo"
    var searchVideoList = [VideoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        searchBox.keyboardAppearance = .Dark
        searchBox.delegate = self
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.hidden = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchVideoList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath)
        let row = indexPath.row
        let video = searchVideoList[row]
        
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchVideoList.removeAll()
        if let searchKey = searchBar.text {
            loadSearchVideoListData(searchKey)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchTableView.hidden = true
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchBox.resignFirstResponder()
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        searchBox.center.y = sy - scrollView.contentOffset.y
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == videoSegueIdentifier {
            let vc = segue.destinationViewController as! VideoViewController
            let indexPath = searchTableView.indexPathForSelectedRow
            
            vc.curVideo = searchVideoList[indexPath!.row]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBox.resignFirstResponder()
    }
    
    func loadSearchVideoListData(key: String) {
        let url = NSURL(string: "http://urinx.sinaapp.com/vu.json?search=\(key)")
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
                        
                        self.searchVideoList.append(VideoModel(title: title, src: src, thumbnail: thumbnail, views: views, comments: comments, time: time))
                    }
                } catch {
                    // ...
                }
            }
            
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                if self.searchVideoList.count == 0 {
                    self.view.makeToast(message: "换个关键词试试~ ^_^")
                }
                self.searchTableView.reloadData()
                self.searchTableView.hidden = false
            })
        }
    }

}

