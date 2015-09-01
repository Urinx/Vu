//
//  LikedViewController.swift
//  唯舞
//
//  Created by Eular on 8/26/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit
import CoreData

class LikedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var likedVideoTableView: UITableView!
    @IBOutlet weak var likedSearchBar: UISearchBar!
    @IBOutlet weak var textLabel: UILabel!
    
    let likedVideoCellIdentifier = "likedVideoCell"
    var likedVideoList = [NSManagedObject]()
    var curVideo: VideoModel?
    var nickname: String!
    var headimgurl: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        likedVideoTableView.dataSource = self
        likedVideoTableView.delegate = self
        likedSearchBar.delegate = self
        
        let info = NSUserDefaults.standardUserDefaults().objectForKey("userInfo")!
        nickname = info["nickname"] as! String
        headimgurl = info["headimgurl"] as! String
        
        if let result = fetchResultInCoreData("LikedVideo") {
            likedVideoList = result
        }
        if likedVideoList.count == 0 {
            likedVideoTableView.hidden = true
            textLabel.hidden = false
        } else {
            likedVideoTableView.hidden = false
            textLabel.hidden = true
        }
        
        // Hide searchBar
        var contentOffset = likedVideoTableView.contentOffset
        contentOffset.y += likedSearchBar.frame.size.height
        likedVideoTableView.contentOffset = contentOffset
        
        changeCancelButtonTitle("编辑")
    }
    
    // Change the title of cancel button in searchBar
    func changeCancelButtonTitle(title: String) {
        for subView in likedSearchBar.subviews[0].subviews {
            if subView.isKindOfClass(NSClassFromString("UINavigationButton")!) {
                let cancelButton = subView as! UIButton
                cancelButton.setTitle(title, forState: UIControlState.Normal)
            }
        }
    }
    
    func getTimeString(timestamp: String) -> String {
        let ago = NSDate(timeIntervalSince1970: NSTimeInterval(timestamp)!)
        let now = NSDate()
        let dt = NSDate(timeIntervalSince1970: NSTimeInterval(String(now.timeIntervalSince1970 - ago.timeIntervalSince1970))!)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        let day = Int(formatter.stringFromDate(dt))!
        if day == 1 {
            return "今天"
        } else if day <= 31 {
            return "\(day - 1)天前"
        } else {
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.stringFromDate(dt)
        }
    }
    
    func fetchResultInCoreData(entityName: String) -> [NSManagedObject]? {
        // 1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // 2
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        // 3
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            return fetchedResults?.reverse()
        } catch {}
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likedVideoList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(likedVideoCellIdentifier, forIndexPath: indexPath)
        let row = indexPath.row
        let video = likedVideoList[row]
        
        let title = video.valueForKey("title") as! String
        let thumbnail = video.valueForKey("thumbnail") as! String
        let timestamp = video.valueForKey("timestamp") as! String

        let headUI = cell.viewWithTag(1) as! UIImageView
        let thumbnailUI = cell.viewWithTag(2) as! UIImageView
        let nameUI = cell.viewWithTag(3) as! UILabel
        let titleUI = cell.viewWithTag(4) as! UILabel
        let timeUI = cell.viewWithTag(5) as! UILabel
        
        headUI.imageFromUrl(headimgurl)
        thumbnailUI.imageFromUrl(thumbnail)
        nameUI.text = nickname
        titleUI.text = title
        timeUI.text = getTimeString(timestamp)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let video = likedVideoList[indexPath.row]
        let title = video.valueForKey("title") as! String
        let thumbnail = video.valueForKey("thumbnail") as! String
        let src = video.valueForKey("src") as! String
        curVideo = VideoModel(title: title, src: src, thumbnail: thumbnail, views: "-", comments: "-", time: "")
        
        self.performSegueWithIdentifier("jumpToVideo", sender: self)
    }
    
    // Edit
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Delete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let row = indexPath.row
            let video = likedVideoList[row]
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext.deleteObject(video)
            
            do {
                try managedContext.save()
            } catch {
                print("Error: Delete failed")
            }
            
            likedVideoList.removeAtIndex(row)
            likedVideoTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    // Drag & Move
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let video = likedVideoList.removeAtIndex(sourceIndexPath.row)
        likedVideoList.insert(video, atIndex: destinationIndexPath.row)
    }
    
    // Edit Mode
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        likedVideoTableView.setEditing(editing, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        if editing {
            changeCancelButtonTitle("编辑")
        } else {
            changeCancelButtonTitle("完成")
        }
        editing = !editing
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
