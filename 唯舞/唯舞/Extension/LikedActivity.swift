//
//  LikedActivity.swift
//  唯舞
//
//  Created by Eular on 8/26/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit

class LikedActivity: UIActivity {
    
    override func activityTitle() -> String? {
        return "收藏"
    }
    
    override func activityImage() -> UIImage? {
        return UIImage(named:"liked")
    }
    
    override func activityType() -> String? {
        return LikedActivity.self.description()
    }
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Action
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func performActivity() {
        NSNotificationCenter.defaultCenter().postNotificationName("LikedNotification", object: nil)
    }
    
}
