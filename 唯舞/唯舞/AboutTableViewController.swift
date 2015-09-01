//
//  AboutTableViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/22.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = UIView()
        let footerView = UIView()
        let AppIconView = UIImageView()
        let AppLabel = UILabel()
        let copyrightLabel = UILabel()
        let ratio = self.view.bounds.size.height / 568
        
        headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 160 * ratio)
        headerView.backgroundColor = UIColor(red: 245 / 256, green: 245 / 256, blue: 245 / 256, alpha: 1)
        AppIconView.image = UIImage(named: "App")
        AppIconView.frame = CGRectMake(self.view.bounds.size.width / 2 - 40 * ratio, 20 * ratio, 80 * ratio, 80 * ratio)
        headerView.addSubview(AppIconView)
        
        AppLabel.frame = CGRectMake(0, 110 * ratio, headerView.frame.width, 30)
        AppLabel.text = "唯舞 Vhiphop 1.0.0"
        AppLabel.textColor = UIColor.grayColor()
        AppLabel.font = UIFont(name: AppLabel.font.fontName, size: 17)
        AppLabel.textAlignment = .Center
        headerView.addSubview(AppLabel)
        
        footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - headerView.frame.height - 255 )
        footerView.backgroundColor = UIColor(red: 245 / 256, green: 245 / 256, blue: 245 / 256, alpha: 1)
        copyrightLabel.frame = CGRectMake(0, footerView.frame.height - 20, footerView.frame.width, 20)
        copyrightLabel.text = "Copyright © 2015 - 2025 Eular. All rights reserved."
        copyrightLabel.textColor = UIColor.grayColor()
        copyrightLabel.font = UIFont(name: copyrightLabel.font.fontName, size: 12 * ratio)
        copyrightLabel.textAlignment = .Center
        footerView.addSubview(copyrightLabel)
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var scene = WXSceneSession.rawValue
        var share = false
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
            case 0:
                // 引导页
                if let pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as? PageViewController {
                    self.presentViewController(pageViewController, animated: true, completion: nil)
                }
            case 2:
                share = true
                scene = WXSceneSession.rawValue
            case 3:
                share = true
                scene = WXSceneTimeline.rawValue
            default:
                break
        }
        
        if share {
            let message =  WXMediaMessage()
            
            message.title = "我发现这个应用炒鸡有趣！"
            message.description = "Vhiphop － 唯舞街舞视频"
            message.setThumbImage(UIImage(named: "App"))
            
            let ext =  WXWebpageObject()
            ext.webpageUrl = AppDownload
            message.mediaObject = ext
            
            let req =  SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = scene
            WXApi.sendReq(req)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as? MyQRCodeViewController
        vc?.isAuthor = true
    }
}
