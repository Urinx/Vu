//
//  LoginViewController.swift
//  唯舞
//
//  Created by Eular on 8/24/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"weixinLogined:", name: WeixinLoginNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func weixinLogined(notification: NSNotification) {
        let info = notification.userInfo as! Dictionary<String, AnyObject>
        NSUserDefaults.standardUserDefaults().setObject(info, forKey: "userInfo")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isLogined")
        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }

    @IBAction func weixinLoginBtnTapped(sender: AnyObject) {
        WXApi.registerApp(HaidaiWXCode)
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo,snsapi_base"
        WXApi.sendReq(req)
    }
}
