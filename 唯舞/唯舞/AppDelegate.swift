//
//  AppDelegate.swift
//  唯舞
//
//  Created by Eular on 15/8/15.
//  Copyright © 2015年 Eular. All rights reserved.
//

import UIKit
import CoreData

let VuWXCode = "wxf104cb037921d767"
let ShareSDKWXCode = "wx4868b35061f87885"
let HaidaiWXCode = "wx6eada1db861b4651"
let HaidaiWXSecret = "9f0506b2c0ee777eff4532f316ffdf91"
let WeixinLoginNotification = "WeixinOauth2Back"
let VuNotification = "VuIndexVideo"
let AppDownload = "http://pre.im/1820"
let AuthorGithub = "http://urinx.github.io"
let VuAllDataApi = "http://urinx.sinaapp.com/vu.json?tag=&page=1"
let pathArr = ["/routines/","/battles/","/info/"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate{

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        UITabBar.appearance().barTintColor = UIColor.blackColor()
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        UITabBar.appearance().barStyle = UIBarStyle.Black
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState: UIControlState.Normal)
        
        NSURLProtocol.registerClass(VuURLProtocol)
        WXApi.registerApp(VuWXCode)
        
        //开启通知
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound],
            categories: nil)
        application.registerUserNotificationSettings(settings)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // iOS会自行以它认定的最佳时间来唤醒程序
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    //后台获取数据
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let entityName = "Explore"
        let url = NSURL(string: VuAllDataApi)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            if error != nil {
                print(error?.code)
                print(error?.description)
                // 让OS知道获取数据失败
                completionHandler(UIBackgroundFetchResult.Failed)
            } else {
                do {
                    let vuJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    let newList = vuJson.objectForKey("new") as! NSArray
                    var check = true
                    var d: NSDictionary!
                    for i in newList.reverse() {
                        d = i as! NSDictionary
                        let md5 = (d["src"] as! String).md5
                        if check {
                            if !isInCoreData(entityName, format: "md5= '\(md5)'") {
                                check = false
                                saveInCoreData(entityName, dict: d, md5: md5)
                            }
                        } else {
                            saveInCoreData(entityName, dict: d, md5: md5)
                        }
                    }
                    
                    if !check {
                        //创建UILocalNotification来进行本地消息通知
                        let localNotification = UILocalNotification()
                        //推送时间（立刻推送）
                        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
                        //时区
                        localNotification.timeZone = NSTimeZone.defaultTimeZone()
                        //推送内容
                        let title = d["title"] as! String
                        localNotification.alertBody = "新的街舞视频来了，快来看看吧！\(title)"
                        //声音
                        localNotification.soundName = UILocalNotificationDefaultSoundName
                        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                        //让OS知道已经获取到新数据
                        completionHandler(UIBackgroundFetchResult.NewData)
                    }
                    
                } catch {
                    completionHandler(UIBackgroundFetchResult.NoData)
                }
            }
        }
        // 启动任务
        task!.resume()
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == "vu" {
            NSNotificationCenter.defaultCenter().postNotificationName(VuNotification, object: nil, userInfo: ["query":url.query!])
        }
        return WXApi.handleOpenURL(url, delegate: self)
    }
    
    func onResp(resp: BaseResp!) {
        /*
        ErrCode  ERR_OK = 0(用户同意)
        ERR_AUTH_DENIED = -4（用户拒绝授权）
        ERR_USER_CANCEL = -2（用户取消）
        */
        
        if resp.isKindOfClass(SendMessageToWXResp) {
            // ...
        } else if resp.errCode == 0 {
            if let code = resp.valueForKey("code") as? String {
                // print(code)
                WXApi.registerApp(VuWXCode)
                
                // 通过code获取access_token
                let url = NSURL(string: "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(HaidaiWXCode)&secret=\(HaidaiWXSecret)&code=\(code)&grant_type=authorization_code")
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                    if error == nil {
                        do {
                            let value = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                            if value.objectForKey("errcode") == nil {
                                let accessToken = value.objectForKey("access_token") as! String
                                let openid = value.objectForKey("openid") as! String
                                self.getUserInfo(accessToken, openid: openid)
                            }
                        } catch {}
                    }
                }
                task!.resume()
            }
        }
    }
    
    func getUserInfo(accessToken: String, openid: String) {
        let url = NSURL(string: "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openid)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if error == nil {
                do {
                    let info = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
                    if info.objectForKey("errcode") == nil {
                        // print(info)
                        let openid = info.objectForKey("openid") as! String
                        let nickname = info.objectForKey("nickname") as! String
                        let headimgurl = info.objectForKey("headimgurl") as! String
                        let city = info.objectForKey("city") as! String
                        let province = info.objectForKey("province") as! String
                        let sex = info.objectForKey("sex") as! Int
                        
                        let center = NSNotificationCenter.defaultCenter()
                        center.postNotificationName(WeixinLoginNotification, object: nil, userInfo: ["openid": openid, "nickname": nickname, "headimgurl": headimgurl, "city": city, "province": province, "sex": sex])
                    }
                } catch {}
            }
        }
        task!.resume()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.eular.test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("vu", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

