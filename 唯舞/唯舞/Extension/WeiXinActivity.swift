//
//  WeiXinActivity.swift
//  唯舞
//
//  Created by Eular on 15/8/18.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit

class WeiXinActivity: UIActivity {
    //用于保存传递过来的要分享的数据
    var text:String!
    var url:NSURL!
    var image:UIImage!
    var scene = WXSceneSession.rawValue
    
    //显示在分享框里的名称
    override func activityTitle() -> String? {
        return "微信"
    }
    
    //分享框的图片
    override func activityImage() -> UIImage? {
        return UIImage(named:"wechat_icon")
    }
    
    //分享类型，在UIActivityViewController.completionHandler回调里可以用于判断，一般取当前类名
    override func activityType() -> String? {
        return WeiXinActivity.self.description()
    }
    
    //按钮类型（分享按钮：在第一行，彩色，动作按钮：在第二行，黑白）
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Share
    }
    
    //是否显示分享按钮，这里一般根据用户是否授权,或分享内容是否正确等来决定是否要隐藏分享按钮
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
    
    //解析分享数据时调用，可以进行一定的处理
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
    
    //执行分享行为
    //这里根据自己的应用做相应的处理
    //例如你可以分享到另外的app例如微信分享，也可以保存数据到照片或其他地方，甚至分享到网络
    override func performActivity() {
        //print("performActivity")
        
        let message =  WXMediaMessage()
        
        message.title = "Vhiphop － 唯舞街舞视频"
        message.description = text
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
    
    //分享时调用
    override func activityViewController() -> UIViewController? {
        // print("activityViewController")
        return nil
    }
    
    //完成分享后调用
    override func activityDidFinish(completed: Bool) {
        // print("activityDidFinish")
    }
}
