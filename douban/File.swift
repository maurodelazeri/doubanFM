//
//  File.swift
//  douban
//
//  Created by 郭振永 on 15/1/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
protocol HTTPProtocol {
    func useContentData(data: NSDictionary)
}

class HTTPHelper: NSObject {
    var delegate: HTTPProtocol!
    
    func getContent(url: String) {
        let theUrl: NSURL = NSURL(string: url)!
        let request = NSURLRequest(URL: theUrl)
        let queue: NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {(response: NSURLResponse!, responseData: NSData!, error: NSError!) -> Void in
            if error != nil {
                println(error.description)
            } else {
                var data = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                self.delegate?.useContentData(data)
            }
            
        })
    }
}
