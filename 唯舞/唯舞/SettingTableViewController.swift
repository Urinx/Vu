//
//  SettingTableViewController.swift
//  唯舞
//
//  Created by Eular on 8/25/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var cacheSizeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = UIView()
        let footerView = UIView()
        
        headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 22)
        headerView.backgroundColor = UIColor(red: 240 / 256, green: 240 / 256, blue: 240 / 256, alpha: 1)
        
        footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 22)
        footerView.backgroundColor = UIColor(red: 240 / 256, green: 240 / 256, blue: 240 / 256, alpha: 1)
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        
        let fileMgr = NSFileManager.defaultManager()
        let cachePath = NSHomeDirectory() + "/Library/Caches/"
        do {
            let attr: NSDictionary = try fileMgr.attributesOfItemAtPath(cachePath)
            let size = attr.fileSize()
            cacheSizeLabel.text = "\(size / 1024)M"
        } catch {}
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let fileMgr = NSFileManager.defaultManager()
            let cachePath = NSHomeDirectory() + "/Library/Caches/"
            do {
                try fileMgr.removeItemAtPath(cachePath)
                try fileMgr.createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: nil)
                cacheSizeLabel.text = "0M"
            } catch {
                print("Error: clean cache failed.")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
