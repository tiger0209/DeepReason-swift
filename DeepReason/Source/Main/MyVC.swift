//
//  MyTabVC.swift
//  DeepReason
//
//  Created by Sierra on 7/10/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import TwilioVoice
import PushKit
import JSQMessagesViewController
import Alamofire
import SwiftyJSON
import Contacts

class MyVC: JSQMessagesViewController {
    var voipRegistry:PKPushRegistry
    var deviceTokenString:String?
    var contentView : UIView?

    @IBOutlet weak var btnProfile: UIBarButtonItem!
    @IBOutlet weak var btnFeed: UIBarButtonItem!
    @IBOutlet weak var btnChat: UIBarButtonItem!

    var childVC : TabRootVC?
    var currentIndex = 0
    
    var shapeLayer : CAShapeLayer?
    let locationManager = CLLocationManager()
    
    var lastTimestamp : Date?
    override func viewDidLoad() {
        super.viewDidLoad()

        let bg = UIImageView(image: UIImage(named: "logo.jpg"))
        bg.frame = view.bounds
        bg.layer.zPosition = -1000
        bg.isUserInteractionEnabled = false
        self.view.addSubview(bg)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.zPosition = -1000
        blurEffectView.isUserInteractionEnabled = false
        self.view.addSubview(blurEffectView)

        let frame : CGRect = (self.navigationController?.view.bounds)!
        let height = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height
        
        contentView = UIView()
        contentView?.frame = CGRect(x: 0, y: height, width: frame.size.width, height: frame.size.height - height)
        contentView?.isUserInteractionEnabled = false
        contentView?.isHidden = true
        self.view.addSubview(contentView!)

        shapeLayer = CAShapeLayer()
        shapeLayer?.strokeColor = UIColor.white.cgColor
        shapeLayer?.lineWidth = 1.0;
        shapeLayer?.fillColor = UIColor.clear.cgColor
        self.navigationController?.navigationBar.layer.addSublayer(shapeLayer!)
        let standard = UserDefaults.standard
        if standard.bool(forKey: Permissions.location) {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
        super.init(coder: aDecoder)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
    }
    func getPosition(item : UIBarButtonItem?) -> CGPoint {
        let view = item?.value(forKey: "view") as? UIView
        return (view?.center)!
    }
}

extension MyVC: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations[0]
        var latitude = loc.coordinate.latitude
        var longitude = loc.coordinate.longitude
        latitude =  50.402146898869015
        longitude = 4.44015656526845
        
        let userDefaults = UserDefaults.standard
        let token = userDefaults.string(forKey: UserProfile.token) ?? ""
        let now = Date()
        let interval : TimeInterval = (lastTimestamp != nil) ? now.timeIntervalSince(lastTimestamp!) : 0.0

        if (lastTimestamp == nil || interval >= 5 * 60) {
            lastTimestamp = now;
            let param : Parameters = [
                UserProfile.token: token,
                "lat": latitude,
                "long": longitude
            ]
            print("Location: \(latitude), \(longitude)")
            Alamofire.request(LOCATION_ENDPOINT, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { _ in
            }
        }
    }
}

extension MyVC {
    func addChildVC(vc: TabRootVC?) {
        self.addChildViewController(childVC!)
        let frame = childVC?.view.frame
        childVC?.view.frame = CGRect(x: frame!.origin.x, y: frame!.origin.y, width: frame!.size.width, height: (contentView?.frame.size.height)!)
        contentView?.addSubview((childVC?.view)!)
        self.navigationController!.didMove(toParentViewController: childVC)
        contentView?.isHidden = false
        self.inputToolbar.isHidden = true
        contentView?.isUserInteractionEnabled = true
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        disableChannel()
    }
    @IBAction func actionProfile(_ sender: UIBarButtonItem) {
        if (contentView?.isHidden == false) {
            childVC?.willMove(toParentViewController: nil)
            childVC?.removeFromParentViewController()
            childVC?.view.removeFromSuperview()
            if (currentIndex == 1) {
                currentIndex = 0
                self.inputToolbar.isHidden = false
                contentView?.isUserInteractionEnabled = false
                removeLine()
                enableChannel()
                return
            }
        }
        childVC = self.storyboard?.instantiateViewController(withIdentifier: "profile") as? TabRootVC
        drawline(x : getPosition(item: btnProfile).x)
        addChildVC(vc:childVC)
        currentIndex = 1
    }
    @IBAction func actionFeed(_ sender: UIBarButtonItem) {
        if (contentView?.isHidden == false) {
            childVC?.willMove(toParentViewController: nil)
            childVC?.removeFromParentViewController()
            childVC?.view.removeFromSuperview()
            if (currentIndex == 2) {
                currentIndex = 0
                self.inputToolbar.isHidden = false
                contentView?.isUserInteractionEnabled = false
                removeLine()
                enableChannel()
                return
            }
        }
        childVC = self.storyboard?.instantiateViewController(withIdentifier: "feed") as? TabRootVC
        drawline(x : getPosition(item: btnFeed).x)
        addChildVC(vc:childVC)
        currentIndex = 2
    }
    @IBAction func actionChat(_ sender: UIBarButtonItem) {
        if (contentView?.isHidden == false) {
            childVC?.willMove(toParentViewController: nil)
            childVC?.removeFromParentViewController()
            childVC?.view.removeFromSuperview()
            if (currentIndex == 3) {
                currentIndex = 0
                self.inputToolbar.isHidden = false
                contentView?.isUserInteractionEnabled = false
                removeLine()
                enableChannel()
                return
            }
        }
        childVC = self.storyboard?.instantiateViewController(withIdentifier: "chat_list") as? TabRootVC
        drawline(x : getPosition(item: btnChat).x)
        addChildVC(vc:childVC)
        currentIndex = 3
    }
    @IBAction func actionServerChat(_ sender: UIBarButtonItem) {
        if (contentView?.isHidden == false) {
            childVC?.willMove(toParentViewController: nil)
            childVC?.removeFromParentViewController()
            childVC?.view.removeFromSuperview()
            currentIndex = 0
            self.inputToolbar.isHidden = false
            contentView?.isUserInteractionEnabled = false
        }
        removeLine()
    }
    func drawline(x arrowX : CGFloat) {
        let height = (self.navigationController?.navigationBar.bounds.height)!
        let status_height = UIApplication.shared.statusBarFrame.height / 2
        let frame = self.view.bounds
        let x = CGFloat(arrowX)
        
//        let mask = CAShapeLayer()
//        mask.path = UIBezierPath(width: frame.width, height: frame.height, diffHeight: status_height, x : x).cgPath
//        view.layer.mask = mask
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: x - status_height * 0.6, y: height))
        path.addLine(to: CGPoint(x: x, y: height - status_height))
        path.addLine(to: CGPoint(x: x + status_height * 0.6, y: height))
        path.addLine(to: CGPoint(x: frame.width, y: height))

        shapeLayer?.path = path.cgPath
    }
    func removeLine() {
        shapeLayer?.path = nil
        contentView?.isHidden = true
    }
    func enableLocation() {
        let standard = UserDefaults.standard
        if standard.bool(forKey: Permissions.location) {
            return
        }
        standard.set(true, forKey: Permissions.location)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    func enableContact() {
        let standard = UserDefaults.standard
        if standard.bool(forKey: Permissions.contact) {
            return
        }
        standard.set(true, forKey: Permissions.contact)
        let addressBookStore = CNContactStore()
        addressBookStore.requestAccess(for: CNEntityType.contacts) { (isGranted, error) in
            print(isGranted)
            print(error)
        }
    }
    func enableChannel() {
    
    }
    func disableChannel() {
    
    }
}

extension MyVC : PKPushRegistryDelegate {
    // MARK: PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        NSLog("pushRegistry:didUpdatePushCredentials:forType:");
        
        if (type != .voIP) {
            return
        }
        
        guard let accessToken = UserDefaults.standard.string(forKey: UserProfile.accessToken) else {
            return
        }
        let deviceToken = (credentials.token as NSData).description

        TwilioVoice.sharedInstance().register(withAccessToken: accessToken, deviceToken: deviceToken) { (error) in
            if (error != nil) {
                NSLog("An error occurred while registering: \(String(describing: error?.localizedDescription))")
            }
            else {
                NSLog("Successfully registered for VoIP push notifications.")
            }
        }
        self.deviceTokenString = deviceToken
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenForType type: PKPushType) {
        NSLog("pushRegistry:didInvalidatePushTokenForType:")
        if (type != .voIP) {
            return
        }
        guard let deviceToken = deviceTokenString, let accessToken = UserDefaults.standard.string(forKey: UserProfile.accessToken) else {
            return
        }
        TwilioVoice.sharedInstance().unregister(withAccessToken: accessToken, deviceToken: deviceToken) { (error) in
            if (error != nil) {
                NSLog("An error occurred while unregistering: \(String(describing: error?.localizedDescription))")
            } else {
                NSLog("Successfully unregistered from VoIP push notifications.")
            }
        }
        self.deviceTokenString = nil
    }
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        NSLog("pushRegistry:didReceiveIncomingPushWithPayload:forType:")
        
        if (type == PKPushType.voIP) {
            if (CallVC.instance == nil) {
                self.performSegue(withIdentifier: "call", sender: self)
                CallVC.instance?.parentVC = self
            }
            TwilioVoice.sharedInstance().handleNotification(payload.dictionaryPayload, delegate: CallVC.instance)
        }
        if (type != .voIP) {
            return
        }
    }
}
