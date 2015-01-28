//
//  ViewController.swift
//  douban
//
//  Created by 郭振永 on 15/1/12.
//  Copyright (c) 2015年 guozy. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HTTPProtocol {
    
    var httpHelper: HTTPHelper = HTTPHelper()
    var songs: NSArray! = []
    var imageCache = Dictionary<String, UIImage>()
    var audioPlayer: MPMoviePlayerController = MPMoviePlayerController()
    var timer:NSTimer!

    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var songsTableView: UITableView!
    @IBOutlet weak var playBtn: UIImageView!
    @IBOutlet var tap: UITapGestureRecognizer!
    
    @IBAction func togglePlay(sender: UITapGestureRecognizer) {
        if sender.view == playBtn {
            playBtn.hidden = true
            audioPlayer.play()
            playBtn.removeGestureRecognizer(tap)
            bigImage.addGestureRecognizer(tap)
        }else if sender.view == bigImage {
            playBtn.hidden = false
            audioPlayer.pause()
            bigImage.removeGestureRecognizer(tap)
            playBtn.addGestureRecognizer(tap)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        httpHelper.delegate = self
        httpHelper.getContent("http://douban.fm/j/mine/playlist?channel=0")
        view.layer.cornerRadius = 3
        progress.progress = 0.0
        bigImage.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return songs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("songs", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = songs[indexPath.row]["title"] as? String
        cell.detailTextLabel?.text = songs[indexPath.row]["artist"] as? String
        cell.imageView?.image = UIImage(named: "detail.jpg")
        let imageUrl = songs[indexPath.row]["picture"] as String
        if (imageCache[imageUrl]? != nil) {
            cell.imageView?.image = imageCache[imageUrl]
        } else {
            let url = NSURL(string: imageUrl)
            let request = NSURLRequest(URL: url!)
            let queue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if data != nil {
                    cell.imageView?.image = UIImage(data: data)
                    self.imageCache[imageUrl] = UIImage(data: data)
                }
            })
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song = songs[indexPath.row] as NSDictionary
        playSong(song["url"] as String)
        setImage(song["picture"] as String)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    @IBAction func selectChannel (segue: UIStoryboardSegue) {
        let chanelVC: ChanelViewController = segue.sourceViewController as ChanelViewController
        if let chanelID = chanelVC.chanelID as? String {
            httpHelper.getContent("http://douban.fm/j/mine/playlist?channel=\(chanelID)")
        }
    }

    
    func playSong(url: String) {
        playBtn.hidden = true
        playBtn.removeGestureRecognizer(tap)
        bigImage.addGestureRecognizer(tap)
        timer?.invalidate()
        audioPlayer.stop()
        audioPlayer.contentURL = NSURL(string: url)
        audioPlayer.play()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "updataTime", userInfo: nil, repeats: true)
    }
    
    func setImage(imageUrl: String) {
        if (imageCache[imageUrl]? != nil) {
            bigImage.image = imageCache[imageUrl]
        } else {
            let url = NSURL(string: imageUrl)
            let request = NSURLRequest(URL: url!)
            let queue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if data != nil {
                    self.bigImage.image = UIImage(data: data)
                    self.imageCache[imageUrl] = UIImage(data: data)
                }
            })
        }
    }
    
    func updataTime() {
        let currentTime = audioPlayer.currentPlaybackTime
        if currentTime > 0{
            let time = audioPlayer.duration
            progress.setProgress(Float(currentTime / time), animated: true)
            let min = ((Int(time) - Int(currentTime)) / 60) as Int
            let sec = (Int(time) - Int(currentTime)) % 60 as Int
            var timeString: String = ""
            if min < 10 {
                timeString += "0\(min):"
            } else {
                timeString += "\(min):"
            }
            if sec < 10 {
                timeString += "0\(sec)"
            } else {
                timeString += "\(sec)"
            }
            timeLabel.text = timeString
        }
    }
    
    func useContentData(data: NSDictionary) {
        songs = data["song"] as NSArray
        dispatch_async(dispatch_get_main_queue()) {
            self.songsTableView.reloadData()
        }
        
        let firstSong = songs[0] as NSDictionary
        playSong(firstSong["url"] as String)
        setImage(firstSong["picture"] as String)
    }
}

