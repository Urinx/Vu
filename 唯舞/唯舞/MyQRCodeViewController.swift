//
//  MyQRCodeViewController.swift
//  唯舞
//
//  Created by Eular on 8/26/15.
//  Copyright © 2015 eular. All rights reserved.
//

import UIKit
import CoreGraphics

class MyQRCodeViewController: UIViewController {
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var QRImageView: UIImageView!
    var isAuthor: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if isAuthor {
            headImageView.image = UIImage(named: "authorHead")
            nameLabel.text = "Ai"
            QRImageView.image = QRCode().make(AuthorGithub)
        } else {
            let info = NSUserDefaults.standardUserDefaults().objectForKey("userInfo")!
            let nickname = info["nickname"] as! String
            let headimgurl = info["headimgurl"] as! String
            headImageView.imageFromUrl(headimgurl)
            nameLabel.text = nickname
            QRImageView.image = QRCode().make(AppDownload)
        }
        
        // let qrcode = createNonInterpolatedUIImageFormCIImage(createQRForString("123"), withSize: CGFloat(250))
        
        // set shadow
        QRImageView.layer.shadowOffset = CGSizeMake(0, 2)
        QRImageView.layer.shadowRadius = 2
        QRImageView.layer.shadowColor = UIColor.blackColor().CGColor
        QRImageView.layer.shadowOpacity = 0.5
    
    }
    
    // --------------------------------------------------------
    // The followinf code is translate the objc code into swift
    func createQRForString(QRStr: String) -> CIImage {
        // Need to convert the string to a UTF-8 encoded NSData object
        let strData = QRStr.dataUsingEncoding(NSUTF8StringEncoding)
        // Create the filter
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        // Set the message content and error-correction level
        qrFilter.setValue(strData, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        // Send the image back
        return qrFilter.outputImage
    }
    
    func createNonInterpolatedUIImageFormCIImage(image: CIImage, withSize size: CGFloat) -> UIImage {
        let extent = CGRectIntegral(image.extent)
        let scale = min(size / extent.width, size / extent.height)
        // create a bitmap image that we'll draw into a bitmap context at the desired size;
        let width = extent.width * scale
        let height = extent.height * scale
        let cs = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, CGImageAlphaInfo.None.rawValue)
        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(image, fromRect: extent)
        CGContextSetInterpolationQuality(bitmapRef, .None)
        CGContextScaleCTM(bitmapRef, scale, scale)
        CGContextDrawImage(bitmapRef, extent, bitmapImage)
        // Create an image with the contents of our bitmap
        let scaledImage = CGBitmapContextCreateImage(bitmapRef)
        // Cleanup
        // CGContext instances are automatically memory managed in Swift
        return UIImage(CGImage: scaledImage!)
    }
    // --------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
