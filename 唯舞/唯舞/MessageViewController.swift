//
//  MessageViewController.swift
//  唯舞
//
//  Created by Eular on 8/28/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var msgTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        msgTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHide:", name: UIKeyboardWillHideNotification, object: nil)

    }
    
    func keyboardShow(note:NSNotification){
        if let info = note.userInfo {
            let  keyboardFrame:CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            let deltay = keyboardFrame.size.height as CGFloat
            scrollView.setContentOffset(CGPointMake(0, deltay), animated: true)
        }
    }
    
    func keyboardHide(note:NSNotification){
        scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
