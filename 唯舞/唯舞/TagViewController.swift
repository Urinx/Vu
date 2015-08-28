//
//  TagViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/21.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MoreViewController
        let btn = sender as! UIButton
        vc.title = btn.titleLabel?.text
        vc.reload = true
        if let id = segue.identifier {
            vc.tag = id.urlencode()
        }
    }

}
