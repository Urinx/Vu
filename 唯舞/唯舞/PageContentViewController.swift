//
//  PageContentViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/19.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeadingLabel: UILabel!
    @IBOutlet weak var pageImage: UIImageView!
    //@IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var StartBtn: UIButton!
    
    var index: Int = 0
    var heading: String = ""
    var subHeading: String = ""
    var img: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        pageImage.image = UIImage(named: img)
        //pageControl.currentPage = index
        StartBtn.hidden = ( index == 3 ) ? false : true
        StartBtn.layer.borderColor = UIColor.whiteColor().CGColor
        StartBtn.layer.borderWidth = 1
        StartBtn.layer.cornerRadius = 5
        
        headingLabel.alpha = 0
        subHeadingLabel.alpha = 0
        pageImage.alpha = 0
        StartBtn.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(2, animations: {
            self.headingLabel.alpha = 1
        })
        UIView.animateWithDuration(2, delay: 2, options: .CurveEaseIn, animations: {
            self.subHeadingLabel.alpha = 1
        }, completion: nil)
        UIView.animateWithDuration(2, delay: 4, options: .CurveEaseIn, animations: {
            self.pageImage.alpha = 1
        }, completion: nil)
        UIView.animateWithDuration(2, delay: 6, options: .CurveEaseIn, animations: {
            self.StartBtn.alpha = 1
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "hasViewedWalkthrough")
        dismissViewControllerAnimated(true, completion: nil)
    }


}
