//
//  InfoTableViewController.swift
//  唯舞
//
//  Created by Eular on 8/25/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var headImage: UIImageView!

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
        
        let info = NSUserDefaults.standardUserDefaults().objectForKey("userInfo")!
        nicknameLabel.text = info["nickname"] as? String
        sexLabel.text = (info["sex"] as? Int) == 1 ? "男" : "女"
        cityLabel.text = (info["province"] as! String) + " " + (info["city"] as! String)
        headImage.imageFromUrl(info["headimgurl"] as! String)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 2 {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLogined")
            navigationController?.popViewControllerAnimated(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
