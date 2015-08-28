//
//  MeTableViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/19.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit

var isLogined: Bool = false

class MeTableViewController: UITableViewController {
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let defaults = NSUserDefaults.standardUserDefaults()
        isLogined = defaults.boolForKey("isLogined")
        if !isLogined {
            nicknameLabel.text = ""
            cityLabel.text = ""
            headImage.image = UIImage(named: "head")
            self.view.makeToast(message: "主人你还没有登录呢...", duration: 1, position: "center")
        } else {
            let info = defaults.objectForKey("userInfo")!
            nicknameLabel.text = info["nickname"] as? String
            cityLabel.text = (info["province"] as! String) + " " + (info["city"] as! String)
            headImage.imageFromUrl(info["headimgurl"] as! String)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section <= 1 {
            if !isLogined {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                let segues = ["infoSegue", "lookedSegue", "likedSegue", "messageSegue"]
                let n = indexPath.section + indexPath.row
                self.performSegueWithIdentifier(segues[n], sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
