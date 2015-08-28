//
//  WeiXinTimelineActivity.swift
//  唯舞
//
//  Created by Eular on 15/8/18.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit

class WeiXinTimelineActivity: UIActivity {
    
    var text:String!
    var url:NSURL!
    var image:UIImage!
    var scene = WXSceneTimeline.rawValue
    
    override func activityTitle() -> String? {
        return "朋友圈"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named:"wechat_moments_icon")
    }
    
    override func activityType() -> String? {
        return WeiXinTimelineActivity.self.description()
    }
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Share
    }

    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        for item in activityItems {
            if item is UIImage {
                return true
            }
            if item is String {
                return true
            }
            if item is NSURL {
                return true
            }
        }
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        // print("prepareWithActivityItems")
        for item in activityItems {
            if item is UIImage {
                image = item as! UIImage
            }
            if item is String {
                text = item as! String
            }
            if item is NSURL {
                url = item as! NSURL
            }
        }
    }

    override func performActivity() {
        let message =  WXMediaMessage()
        
        message.title = text
        message.description = "Vhiphop － 唯舞街舞视频"
        message.setThumbImage(image)
        
        let ext =  WXWebpageObject()
        ext.webpageUrl = "\(url)"
        message.mediaObject = ext
        
        let req =  SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = scene
        WXApi.sendReq(req)
    }
    
    override func activityViewController() -> UIViewController? {
        // print("activityViewController")
        return nil
    }
    
    override func activityDidFinish(completed: Bool) {
        // print("activityDidFinish")
    }
}
