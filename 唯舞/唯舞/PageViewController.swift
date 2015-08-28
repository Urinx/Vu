//
//  PageViewController.swift
//  唯舞
//
//  Created by Eular on 15/8/19.
//  Copyright © 2015年 eular. All rights reserved.
//

import UIKit
import AVFoundation

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var avPlayer: AVAudioPlayer!
    var pageHeadings = ["", "身在红尘的喧嚣", "回首路过的痕迹", "直到此刻"]
    var subHeadings = ["", "有时会往记自己属于哪道风景", "一直日光倾城", "不为繁华而动，只为宁静而舞"]
    var pageImages = ["g0", "g1", "g2", "g3"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dataSource = self
        if let startingViewController = self.viewControllerAtIndex(0) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion: nil)
        }
        
        do {
            avPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Audio Machine - Breath and Life", ofType: "mp3")!))
            avPlayer.play()
        } catch {}
    }
    
    override func viewDidDisappear(animated: Bool) {
        avPlayer.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = ( viewController as! PageContentViewController ).index
        index++
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = ( viewController as! PageContentViewController ).index
        index--
        return viewControllerAtIndex(index)
    }
    
    /* Page Control*/
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageHeadings.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        if let pageView = storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as? PageContentViewController {
            return pageView.index
        }
        return 0
    }
    
    func viewControllerAtIndex(index: Int) -> PageContentViewController? {
        
        if index == NSNotFound || index < 0 || index >= self.pageHeadings.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        if let pageView = storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as? PageContentViewController {
            
            pageView.heading = pageHeadings[index]
            pageView.subHeading = subHeadings[index]
            pageView.img = pageImages[index]
            pageView.index = index
            
            return pageView
        }
        
        return nil
    }

}
