//
//  ProfileVC.swift
//  DeepReason
//
//  Created by Sierra on 7/8/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import TwilioVoice
import AVFoundation
import MediaPlayer
import NVActivityIndicatorView

class CallID {
    static let from = "to"
    static let to = "from"
    static let channel = "channel"
    static let chat_name = "chat_name"
    static let icon = "chat_icon"
}

class CallVC: UIViewController {
    @IBOutlet weak var btnSpeaker: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var lblStatus: UILabel!
    
    public var from: String?
    public var to: String?
    public var itemFrame: CGRect?
    var isClosed = false
    public static var instance: CallVC? = nil

    var callInvite:TVOCallInvite?
    var call:TVOCall?

    var ringtonePlayer:AVAudioPlayer?
    var ringtonePlaybackCallback: (() -> ())?

    var parentVC : UIViewController?;
    var incomingAlertController: UIAlertController?

    var volumn = AVAudioSession.sharedInstance().outputVolume
    
    var isSpeaker = false;
    var isMuted = true;

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        TwilioVoice.sharedInstance().logLevel = .verbose
        CallVC.instance = self
    }
    
    func close() {
//        self.dismiss(animated: true, completion: nil)
        isClosed = true
        self.navigationController?.popViewController(animated: true)
    }
    func stopCall() {
        if (self.call != nil) {
            self.call?.disconnect()
        }
        self.close()
    }
    func placeCall() {
        if (self.call != nil) {
            stopCall()
        } else {
            guard let accessToken = UserDefaults.standard.string(forKey: UserProfile.accessToken) else {
                return
            }
            guard let targetId = UserDefaults.standard.string(forKey: CallID.to) else {
                return
            }
            playOutgoingRingtone(completion: { [weak self] in
                if let strongSelf = self {
                    strongSelf.call = TwilioVoice.sharedInstance().call(accessToken, params: ["target":targetId], delegate: strongSelf)
                    if (strongSelf.call == nil) {
                        NSLog("Failed to start outgoing call")
                        return
                    }
                    if (strongSelf.isClosed) {
                        strongSelf.call?.disconnect()
                    }
                }
            })
        }
    }
    func playIncomingRingtone() {
        let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "incoming", ofType: "wav")!)
        do {
            self.ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
            self.ringtonePlayer?.delegate = self
            self.ringtonePlayer?.numberOfLoops = -1
            playRingtone()
        } catch {
            NSLog("Failed to initialize audio player")
        }
    }
    
    func stopIncomingRingtone() {
        if (self.ringtonePlayer?.isPlaying == false) {
            return
        }
        
        self.ringtonePlayer?.stop()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    func playDisconnectSound() {
        let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "disconnect", ofType: "wav")!)
        do {
            self.ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
            self.ringtonePlayer?.delegate = self
            self.ringtonePlaybackCallback = nil
            
            playRingtone()
        } catch {
            NSLog("Failed to initialize audio player")
        }
    }
    
    func playRingtone() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            NSLog(error.localizedDescription)
        }
        
        self.ringtonePlayer?.volume = 1.0
        self.ringtonePlayer?.play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (self.ringtonePlaybackCallback != nil) {
            DispatchQueue.main.async {
                self.ringtonePlaybackCallback!()
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
}

extension CallVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSpeaker.layer.borderColor = UIColor.white.cgColor
        btnMessage.layer.borderColor = UIColor.white.cgColor
        btnMute.layer.borderColor = UIColor.white.cgColor
        self.placeCall()
        self.actionSpeaker(self.btnSpeaker)
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
extension CallVC : TVONotificationDelegate {
    func callInviteReceived(_ callInvite: TVOCallInvite) {
        NSLog("callInviteReceived:")
        if (self.callInvite != nil && self.callInvite?.state == .pending) {
            NSLog("Already a pending call invite. Ignoring incoming call invite from \(callInvite.from)")
            return
        } else if (self.call != nil && self.call?.state == .connected) {
            NSLog("Already an active call. Ignoring incoming call invite from \(callInvite.from)");
            return;
        }
        self.callInvite = callInvite;
        let from = callInvite.from
        let alertMessage = "From: \(from)"
        playIncomingRingtone()
        let incomingAlertController = UIAlertController(title: "Incoming",
                                                        message: alertMessage,
                                                        preferredStyle: .alert)
        let rejectAction = UIAlertAction(title: "Reject", style: .default) { [weak self] (action) in
            if let strongSelf = self {
                strongSelf.stopIncomingRingtone()
                callInvite.reject()
                strongSelf.callInvite = nil
                strongSelf.incomingAlertController = nil
            }
        }
        incomingAlertController.addAction(rejectAction)
        let ignoreAction = UIAlertAction(title: "Ignore", style: .default) { [weak self] (action) in
            if let strongSelf = self {
                /* To ignore the call invite, you don't have to do anything but just literally ignore it */
                strongSelf.callInvite = nil
                strongSelf.stopIncomingRingtone()
                strongSelf.incomingAlertController = nil
            }
        }
        incomingAlertController.addAction(ignoreAction)
        let acceptAction = UIAlertAction(title: "Accept", style: .default) { [weak self] (action) in
            if let strongSelf = self {
                strongSelf.stopIncomingRingtone()
                strongSelf.call = callInvite.accept(with: strongSelf)
                strongSelf.callInvite = nil
                strongSelf.incomingAlertController = nil
            }
        }
        incomingAlertController.addAction(acceptAction)
        present(incomingAlertController, animated: true, completion: nil)
        self.incomingAlertController = incomingAlertController
        // If the application is not in the foreground, post a local notification
        if (UIApplication.shared.applicationState != UIApplicationState.active) {
            let notification = UILocalNotification()
            notification.alertBody = "Incoming Call From \(from)"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func callInviteCanceled(_ callInvite: TVOCallInvite?) {
        NSLog("callInviteCanceled:")
        if (callInvite?.callSid != self.callInvite?.callSid) {
            NSLog("Incoming (but not current) call invite from \(String(describing: callInvite?.from)) canceled. Just ignore it.");
            return;
        }
        
        self.stopIncomingRingtone()
        playDisconnectSound()
        
        if (incomingAlertController != nil) {
            dismiss(animated: true) { [weak self] in
                if let strongSelf = self {
                    strongSelf.incomingAlertController = nil
                }
            }
        }
        
        self.callInvite = nil
        
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    func notificationError(_ error: Error) {
        NSLog("notificationError: \(error.localizedDescription)")
    }
    
}
extension CallVC :TVOCallDelegate {
    func callDidConnect(_ call: TVOCall) {
        NSLog("callDidConnect:")
        self.call = call
        routeAudioToSpeaker()
        lblStatus.text = "calling"
        self.actionMute(self.btnMute)
    }
    
    func callDidDisconnect(_ call: TVOCall) {
        NSLog("callDidDisconnect:")
        
        playDisconnectSound()
        self.call = nil
        lblStatus.text = "disconnected"
        switch call.state {
        case .connected:
            break
        case .connecting:
            break
        case .disconnected:
            break
        }
        self.close()
    }
    
    func call(_ call: TVOCall?, didFailWithError error: Error) {
        NSLog("call:didFailWithError: \(error.localizedDescription)");
        self.call = nil
        lblStatus.text = "disconnected"
        self.close()
    }

    // MARK: AVAudioSession
    func routeAudioToSpeaker() {
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch {
            NSLog(error.localizedDescription)
        }
    }

}
extension CallVC : AVAudioPlayerDelegate {
    // MARK: Ringtone player & AVAudioPlayerDelegate
    func playOutgoingRingtone(completion: @escaping () -> ()) {
        self.ringtonePlaybackCallback = completion
        
        let ringtonePath = URL(fileURLWithPath: Bundle.main.path(forResource: "outgoing", ofType: "wav")!)
        do {
            self.ringtonePlayer = try AVAudioPlayer(contentsOf: ringtonePath)
            self.ringtonePlayer?.delegate = self
            playRingtone()
        } catch {
            NSLog("Failed to initialize audio player")
            self.ringtonePlaybackCallback?()
        }
    }
}

extension CallVC {
    @IBAction func actionCall(_ sender: Any) {
        self.stopCall()
    }
    
    @IBAction func actionSpeaker(_ sender: Any) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeVoiceChat)
            isSpeaker = !isSpeaker
            if (isSpeaker) {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                btnSpeaker.setImage(UIImage(named: "video_controls_volume_unmute"), for: .normal)
            } else {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                btnSpeaker.setImage(UIImage(named: "video_controls_volume_mute"), for: .normal)
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
    }
    @IBAction func actionMute(_ sender: Any) {
        isMuted = !isMuted
        call?.isMuted = self.isMuted
        if (isMuted) {
            btnMute.setImage(UIImage(named: "icon_mute"), for: .normal)
        } else {
            btnMute.setImage(UIImage(named: "icon_unmute"), for: .normal)
        }
    }
    @IBAction func actionChat(_ sender: Any) {
        self.close()
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "chat")
        self.parentVC?.present(chatVC!, animated: true, completion: nil)
    }
}
