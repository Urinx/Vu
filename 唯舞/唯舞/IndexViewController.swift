//
//  FirstViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/15.
//  Copyright © 2015年 Eular. All rights reserved.
//

import UIKit

class IndexViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let refreshControl = UIRefreshControl()
    var curVideo: VideoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 引导页
        let defaults = NSUserDefaults.standardUserDefaults()
        let hasViewedWalkthrough = defaults.boolForKey("hasViewedWalkthrough")
        if !hasViewedWalkthrough {
            if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController {
                self.presentViewController(pageViewController, animated: true, completion: nil)
            }
        }
        
        let appFile = NSBundle.mainBundle().URLForResource("WebApp/index", withExtension: "html")
        let localRequest = NSURLRequest(URL: appFile!)
        webView.loadRequest(localRequest)
        webView.scalesPageToFit = false
        
        refreshControl.addTarget(self, action: "refreshHTML", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        webView.scrollView.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"vuIndexVideo:", name: VuNotification, object: nil)
    }
    
    func vuIndexVideo(notification: NSNotification) {
        let video = notification.userInfo as! Dictionary<String, AnyObject>
        let query = video["query"] as! String
        var t = [String]()
        for s in query.split("&") {
            t.append(s.split("=")[1])
        }
        if t[0].has("/routines/") || t[0].has("/battles/") {
            // ....
        } else {
            curVideo = VideoModel(title: "", src: t[0], thumbnail: t[1], views: "", comments: "", time: "")
            self.performSegueWithIdentifier("IndexToVideo", sender: self)
        }
    }
    
    func refreshHTML() {
        self.webView.reload()
        self.refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "IndexToVideo" {
            let vc = segue.destinationViewController as! VideoViewController
            vc.curVideo = curVideo
        }
    }
}

