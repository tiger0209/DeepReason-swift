//
//  FeedDetailVC.swift
//  DeepReason
//
//  Created by Zeus on 9/8/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import BButton
import KIImagePager
import SCLAlertView
import SwiftyJSON
import NVActivityIndicatorView
import TwilioChatClient
import Alamofire
import SDWebImage

class FeedDetailVC: UIViewController {
    var feed : Feed?
    
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblBody: UILabel!
    @IBOutlet weak var btnChat: BButton!
    @IBOutlet weak var btnCall: BButton!
    @IBOutlet weak var btnContact: BButton!

    @IBOutlet weak var imagePager: KIImagePager!
    override func viewDidLoad() {
        super.viewDidLoad()

        icon.sd_setImage(with: URL(string: feed!.user_icon))
        bgImg.sd_setImage(with: URL(string: feed!.images[0]), placeholderImage: UIImage(named: "placeholder.png"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        lblTitle.text = feed?.title
        lblLocation.text = feed?.location
        lblTime.text = feed?.time
        lblBody.text = feed?.body
        btnCall.isHidden = !feed!.voice_chat
        btnChat.isHidden = !feed!.text_chat
        btnContact.isHidden = !feed!.contact_chat

        btnCall.setType(.default)
        btnChat.setType(.default)
        btnContact.setType(.default)

        imagePager.dataSource = self

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallVC.instance = nil
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imagePager.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        imagePager.pageControl.pageIndicatorTintColor = UIColor.black
        imagePager.pageControl.center = CGPoint(x: imagePager.frame.size.width / 2, y: imagePager.frame.size.height - 42);
        
        imagePager.slideshowTimeInterval = 3;

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
extension FeedDetailVC : KIImagePagerDataSource {
    func contentMode(forImage image: UInt, in pager: KIImagePager!) -> UIViewContentMode {
        return .scaleAspectFit
    }

    func array(withImages pager: KIImagePager!) -> [Any]! {
        return feed?.images
    }

}

extension FeedDetailVC {
    @IBAction func actionChat(_ sender: Any) {
        let my_id = UserDefaults.standard.string(forKey: UserProfile.id)!
        let my_name = "\(UserDefaults.standard.string(forKey: UserProfile.firstname)!) \(UserDefaults.standard.string(forKey: UserProfile.lastname)!)"
        let target_id : String = feed!.voice_id
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
                self.gotoChat(uniqeName: channel_name, targetName: profile.getName())
                return
            }
        }
        ChannelManager.sharedManager.createChannelWithName(name: channel_name, friendly: friendly_name, completion: {result, channel in
            channel?.members.invite(byIdentity: target_id) { completion in
                //                let success = completion?.isSuccessful()
                //                print(completion?.error)
                ChannelManager.sharedManager.populateChannels() {
                    self.gotoChat(uniqeName: channel_name, targetName: profile.getName())
                }
            }
        });
    }
    
    @IBAction func actionContact(_ sender: Any) {
        self.actionContact()
    }
    @IBAction func actionCall(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        let my_id = userDefaults.string(forKey: UserProfile.id) ?? ""
        userDefaults.setValue(my_id, forKeyPath: CallID.from)
        userDefaults.setValue(feed!.voice_id, forKeyPath: CallID.to)
        performSegue(withIdentifier: "call", sender: self)
        CallVC.instance?.parentVC = self
        self.navigationController?.navigationBar.isHidden = true
    }

}
extension FeedDetailVC {
    func gotoChat(uniqeName: String, targetName: String) {
        UserDefaults.standard.setValue(uniqeName, forKeyPath: CallID.channel)
        UserDefaults.standard.setValue(targetName, forKeyPath: CallID.chat_name)
        UserDefaults.standard.setValue((feed?.user_icon)!, forKeyPath: CallID.icon)
        let childVC = self.storyboard?.instantiateViewController(withIdentifier: "chat")
        self.navigationController?.pushViewController(childVC!, animated: true)
    }
    func actionContact() {
        let userDefaults = UserDefaults.standard
        let token = userDefaults.string(forKey: UserProfile.token) ?? ""
        let param : Parameters = [
            UserProfile.token: token,
            "feed_item": feed!.feed_item_id!
        ]

        Alamofire.request(CONTACT_ENDPOINT, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .failure(let error):
                print(error)
                return
            default:
                break
            }
            if let data = response.data {
                let json = JSON(data: data)
                let status = json["status"].string!
                switch status {
                case "fail":
                    let reason = json["reason"].string!
                    print(reason)
                    return
                default:
                    
                    break
                }
            }
        }
        
    }
}
