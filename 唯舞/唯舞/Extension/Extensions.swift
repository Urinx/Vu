//
//  Extensions.swift
//  唯舞
//
//  Created by Eular on 8/25/15.
//  Copyright © 2015 eular. All rights reserved.
//

import Foundation
import CoreData

extension String {
    // md5 need import <CommonCrypto/CommonCrypto.h> in bridging header file
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
    
    var count: Int {
        return self.characters.count
    }
    
    func split(separator: String) -> [String] {
        return self.componentsSeparatedByString(separator)
    }
    
    func urlencode() -> String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
    }
    
    func replace(before: String, after: String) -> String {
        return self.stringByReplacingOccurrencesOfString(before, withString: after)
    }
    
    func has(subString: String) -> Bool {
        if self.rangeOfString(subString) != nil {
            return true
        }
        return false
    }
}

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        let fileMgr = NSFileManager.defaultManager()
        let cachePath = NSHomeDirectory() + "/Library/Caches/"
        let filePath = cachePath + urlString.md5 + ".png"
        
        if fileMgr.fileExistsAtPath(filePath) {
            let imgData = fileMgr.contentsAtPath(filePath)
            self.image = UIImage(data: imgData!)
        } else {
            if let url = NSURL(string: urlString) {
                let request = NSURLRequest(URL: url)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                    (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                    let img = UIImage(data: data!)
                    self.image = img
                    let imgData = UIImagePNGRepresentation(img!)
                    imgData?.writeToFile(filePath, atomically: true)
                }
            }
        }
    }
}

func isInCoreData(entityName: String, format: String) -> Bool {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    //设置查询条件
    fetchRequest.predicate = NSPredicate(format: format, "")
    do {
        let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        if fetchedResults?.count != 0 {
            return true
        }
    } catch {}
    
    return false
}

func saveInCoreData(entityName: String, dict: NSDictionary, md5: String) -> Bool {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: managedContext)
    let managedObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    for (key, value) in dict {
        managedObj.setValue(value, forKey: key as! String)
    }
    managedObj.setValue(md5, forKey: "md5")
    
    do {
        try managedContext.save()
        return true
    } catch {
        print("Could not save")
        return false
    }
}