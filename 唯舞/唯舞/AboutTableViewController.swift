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
        
        headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 160)
        headerView.backgroundColor = UIColor(red: 245 / 256, green: 245 / 256, blue: 245 / 256, alpha: 1)
        AppIconView.image = UIImage(named: "App")
        AppIconView.frame = CGRectMake(self.view.bounds.size.width / 2 - 40, 20, 80, 80)
        headerView.addSubview(AppIconView)
        
        AppLabel.frame = CGRectMake(0, 110, headerView.frame.width, 30)
        AppLabel.text = "唯舞 Vhiphop 1.0.0"
        AppLabel.textColor = UIColor.grayColor()
        AppLabel.font = UIFont(name: AppLabel.font.fontName, size: 17)
        AppLabel.textAlignment = .Center
        headerView.addSubview(AppLabel)
        
        footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 160)
        footerView.backgroundColor = UIColor(red: 245 / 256, green: 245 / 256, blue: 245 / 256, alpha: 1)
        copyrightLabel.frame = CGRectMake(0, footerView.frame.height - 20, footerView.frame.width, 20)
        copyrightLabel.text = "Copyright © 2015 - 2025 Eular. All rights reserved."
        copyrightLabel.textColor = UIColor.grayColor()
        copyrightLabel.font = UIFont(name: copyrightLabel.font.fontName, size: 12)
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

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

}
