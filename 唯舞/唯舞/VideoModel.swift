//
//  VideoModel.swift
//  唯舞
//
//  Created by Eular on 15/8/17.
//  Copyright © 2015年 Eular. All rights reserved.
//

import UIKit

class VideoModel: NSObject {
    var title: String
    var src: String
    var thumbnail: String
    var views: String
    var comments: String
    var time: String
    
    init(title: String, src: String, thumbnail: String, views: String, comments: String, time: String) {
        self.title = title
        self.src = src
        self.thumbnail = thumbnail
        self.views = views
        self.comments = comments
        self.time = time
    }
}
