//
//  FeedCell.swift
//  DeepReason
//
//  Created by Sierra on 7/18/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import TwilioChatClient
import BButton
import SCLAlertView

class FeedCell: UIView {

    @IBOutlet weak var marginWidth: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var imgBG: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var btnChat: BButton!
    @IBOutlet weak var btnCall: BButton!
    @IBOutlet weak var btnContact: BButton!
    var cell : FDFeedCell?
    @IBAction func actionChat(_ sender: Any) {
        let my_id = UserDefaults.standard.string(forKey: UserProfile.id)!
        let my_name = "\(UserDefaults.standard.string(forKey: UserProfile.firstname)!) \(UserDefaults.standard.string(forKey: UserProfile.lastname)!)"
        let target_id = (cell?.feed?.voice_id)!
        let path = "\(PROFILE_ENDPOINT)?id=\(target_id)"
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
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let profile = UserProfile(dict: json)
        
        var channel_name: String, friendly_name: String
        if my_id > target_id {
            channel_name = "\(target_id):\(my_id)"
            friendly_name = "\(profile.getName()):\(my_name)"
        } else {
            channel_name = "\(my_id):\(target_id)"
            friendly_name = "\(my_name):\(profile.getName())"
        }
        let channels = ChannelManager.sharedManager.channels?.array
        for channel in channels! {
            if ((channel as AnyObject).uniqueName! == channel_name) {
                self.cell?.gotoChat(uniqeName: channel_name, targetName: profile.getName())
                return
            }
        }
        ChannelManager.sharedManager.createChannelWithName(name: channel_name, friendly: friendly_name, completion: {result, channel in
            channel?.members.invite(byIdentity: target_id) { completion in
                //                let success = completion?.isSuccessful()
                //                print(completion?.error)
                ChannelManager.sharedManager.populateChannels() {
                    self.cell?.gotoChat(uniqeName: channel_name, targetName: profile.getName())
                }
            }
        });
    }
    
    @IBAction func actionContact(_ sender: Any) {
        self.cell?.actionContact()
    }
    @IBAction func actionCall(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        let my_id = userDefaults.string(forKey: UserProfile.id) ?? ""
        userDefaults.setValue(my_id, forKeyPath: CallID.from)
        userDefaults.setValue(cell?.feed!.voice_id, forKeyPath: CallID.to)
        cell?.feedVC?.performSegue(withIdentifier: "call", sender: cell?.feedVC)
        CallVC.instance?.parentVC = cell?.feedVC
    }

}
