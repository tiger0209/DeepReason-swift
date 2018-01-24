//
//  ChatListVC.swift
//  DeepReason
//
//  Created by Zeus on 8/4/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import Foundation
import UIKit
import TwilioChatClient
import NVActivityIndicatorView
import SwiftyJSON
import SCLAlertView

class ChatListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    @IBOutlet weak var tableview: UITableView!
    var channels : Array<Any> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.dataSource = self
        self.tableview.delegate = self
        channels = (ChannelManager.sharedManager.channels?.array)!

        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.backgroundColor = UIColor.clear
        navBar?.isTranslucent = true
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame =  (navBar?.bounds)!
        visualEffectView.isUserInteractionEnabled = false
        visualEffectView.layer.zPosition = -10
        navBar?.addSubview(visualEffectView)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Chat History"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = channels.count
        if (count > 0) {
            for i in 0..<count {
                let channel = channels[i]
                let uniqueName = (channel as AnyObject).uniqueName!
                if uniqueName!.contains("sever_") {
                    channels.remove(at: i)
                    break
                }
            }
            return count - 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (cell == nil) {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for : indexPath)
        }
        let channel = channels[indexPath.section]
        let friendlyName = (channel as AnyObject).friendlyName!
        let userNames = friendlyName?.components(separatedBy: ":")
        let my_name = "\(UserDefaults.standard.string(forKey: UserProfile.firstname)!) \(UserDefaults.standard.string(forKey: UserProfile.lastname)!)"
        var targetName = ""
        for i in 0..<2 {
            if (userNames?[i] == my_name) {
                continue
            }
            targetName = userNames![i]
            break
        }
        cell?.textLabel?.text = targetName
        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.clear
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let userDefaults = UserDefaults.standard
            let channel = self.channels[indexPath.section]

            let uniqueName = (channel as AnyObject).uniqueName!
            userDefaults.setValue(uniqueName, forKeyPath: CallID.channel)
            let my_id = userDefaults.string(forKey: UserProfile.id)!
            let ids = uniqueName?.components(separatedBy: ":")
            let targetId = (ids![0] == my_id) ? ids![1] : ids![0]

            let path = "\(PROFILE_ENDPOINT)?id=\(targetId)"
            let res = try? String(contentsOf: URL(string: path)!, encoding: .utf8);
            if res == nil {
                SCLAlertView().showError("Network Error", subTitle: "Please try again later")
                return
            }
            let json = JSON(parseJSON: res!)
            if (json["status"].string! != "ok") {
                //nala error
                return
            }
            let profile = UserProfile(dict: json)
            userDefaults.setValue(profile.getName(), forKeyPath: CallID.chat_name)
            userDefaults.setValue(profile.icon, forKeyPath: CallID.icon)
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
            self.performSegue(withIdentifier: "chat", sender: self)
        }
    }

}
