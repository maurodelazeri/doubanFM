//
//  ChanelViewController.swift
//  douban
//
//  Created by 郭振永 on 15/1/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import QuartzCore

class ChanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , HTTPProtocol{
    let httpHelper: HTTPHelper = HTTPHelper()
    var chanels: NSArray = []
    var chanelID: AnyObject!

    @IBOutlet weak var channelTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        httpHelper.delegate = self
        httpHelper.getContent("http://www.douban.com/j/app/radio/channels")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chanels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chanel", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = chanels[indexPath.row]["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toList" {
            let cell = sender as UITableViewCell
            let index = channelTV.indexPathForCell(cell)
            if let i = index?.row {
                chanelID = chanels[i]["channel_id"]
            }
        }
    }
    
    func useContentData(data: NSDictionary) {
        chanels = data["channels"] as NSArray
        dispatch_async(dispatch_get_main_queue()) {
            self.channelTV.reloadData()
        }
    }
}
