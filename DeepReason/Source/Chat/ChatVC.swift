//
//  ChatViewController.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import TwilioChatClient
import NVActivityIndicatorView
import SwiftyJSON
import Alamofire
import SDWebImage

public enum Setting: String{
    case removeBubbleTails = "Remove message bubble tails"
    case removeSenderDisplayName = "Remove sender Display Name"
    case removeAvatar = "Remove Avatars"
}

class ChatVC: JSQMessagesViewController , UINavigationControllerDelegate {
    public var itemFrame: CGRect?
    
    let defaults = UserDefaults.standard
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var displayName: String!
    var channel : TCHChannel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.collectionView?.backgroundColor = UIColor.clear
        
        if defaults.bool(forKey: Setting.removeBubbleTails.rawValue) {
            incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero, layoutDirection: UIApplication.shared.userInterfaceLayoutDirection).incomingMessagesBubbleImage(with: UIColor.lightGray)
            outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero, layoutDirection: UIApplication.shared.userInterfaceLayoutDirection).outgoingMessagesBubbleImage(with: UIColor(red: 0.2, green: 0.816, blue: 0.75, alpha: 1.0))
        }
        else {
            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.lightGray)
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(red: 0.2, green: 0.816, blue: 0.75, alpha: 1.0))
        }
        if defaults.bool(forKey: Setting.removeAvatar.rawValue) {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        } else {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        }
        collectionView?.collectionViewLayout.springinessEnabled = false
        
        automaticallyScrollsToMostRecentMessage = true
        
        //        inputToolbar.contentView?.leftBarButtonItem = nil
        inputToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        inputToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        inputToolbar.backgroundColor = UIColor.init(white: 1.0, alpha: 0.05)
        inputToolbar.contentView?.textView?.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        inputToolbar.contentView?.textView?.layer.borderWidth = 0
        inputToolbar.contentView?.textView?.textColor = UIColor.white
        self.inputToolbar.isHidden = false

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        let channel_name = UserDefaults.standard.string(forKey: CallID.channel)
        self.loadChannel(channel: channel_name!)
    }

    func loadChannel(channel channel_name : String) {
        let channels = ChannelManager.sharedManager.channels?.array
        for _channel in channels! {
            let uniqueName = (_channel as AnyObject).uniqueName!
            if (uniqueName == channel_name) {
                if _channel is TCHChannel {
                    self.channel = _channel as! TCHChannel
                    channel?.delegate = self
                    if channel?.status != .joined {
                        channel?.join { result in
                            print("Channel Joined")
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        }
                    } else {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    }
                } else {
                    (_channel as? TCHChannelDescriptor)?.channel() { result, channel in
                        self.channel = channel
                        channel?.delegate = self
                        if channel?.status != .joined {
                            channel?.join { result in
                                print("Channel Joined")
                                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                            }
                        } else {
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        }
                    }
                }
                return
            }
        }
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        let message = ChatMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        sendMessage(inputMessage: message)
        self.finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Send Images", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "From Camera", style: .default) { (action) in
            let picker : UIImagePickerController = UIImagePickerController()
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.sourceType = .camera;
            self.present(picker, animated: true, completion: nil)
            
        }
        let galleryAction = UIAlertAction(title: "From Gallery", style: .default) { (action) in
            let picker : UIImagePickerController = UIImagePickerController()
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.sourceType = .photoLibrary;
            self.present(picker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        sheet.addAction(cameraAction)
        sheet.addAction(galleryAction)
        sheet.addAction(cancelAction)

        self.present(sheet, animated: true, completion: nil)
    }
    
//    func buildVideoItem() -> JSQVideoMediaItem {
//        let videoURL = URL(fileURLWithPath: "file://")
//        
//        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
//        
//        return videoItem
//    }
    
//    func buildAudioItem() -> JSQAudioMediaItem {
//        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
//        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
//        
//        let audioItem = JSQAudioMediaItem(data: audioData)
//        
//        return audioItem
//    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = UserDefaults.standard.string(forKey: CallID.chat_name)
        let navBar = self.navigationController?.navigationBar
        navBar?.isHidden = false
        super.viewWillAppear(animated)
    }
    //    func buildLocationItem() -> JSQLocationMediaItem {
    //        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
    //
    //        let locationItem = JSQLocationMediaItem()
    //        locationItem.setLocation(ferryBuildingInSF) {
    //            self.collectionView?.reloadData()
    //            self.collectionView?.layoutIfNeeded()
    //            self.scrollToBottom(animated: true)
    //        }
    //
    //        return locationItem
    //    }
    
    func addMedia(_ media:JSQMediaItem, url: String) {
        let message = ChatMessage(senderId: self.senderId(), displayName: self.senderDisplayName(), media: media)
        self.sendMessage(inputMessage: message, url: url)
        self.finishSendingMessage(animated: true)
    }
    
    func getMyUserName() -> String{
        let defaults = UserDefaults.standard
        return "\(defaults.string(forKey: UserProfile.firstname)!) \(defaults.string(forKey: UserProfile.lastname)!)"
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        self.inputToolbar.contentView?.textView?.resignFirstResponder()
    }
    //MARK: JSQMessages CollectionView DataSource
    
    override func senderId() -> String {
        return (MessagingManager.sharedManager().client?.user.identity)!
    }
    
    override func senderDisplayName() -> String {
        return getName(.Wozniak)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedMessages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let message = sortedMessages[indexPath.item]
        return message
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        let message = sortedMessages[indexPath.item]
        return message.senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return Me
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = UIColor.white
        let message = sortedMessages[indexPath.item]
        var path : URL
        var placeHolder : UIImage
        
        let userDefaults = UserDefaults.standard
        if message.senderId == senderId() {
            path = URL(string: userDefaults.string(forKey: UserProfile.icon)!)!
            placeHolder = Me.avatarImage!
        } else {
            path = URL(string: userDefaults.string(forKey: CallID.icon)!)!
            placeHolder = UIImage(named: "avatar_add_round")!
        }
        cell.avatarImageView?.sd_setImage(with: path, placeholderImage: placeHolder,
                                          options: SDWebImageOptions(rawValue: 0)){ (image, error, cacheType, imageURL) in
                                            if (image != nil) {
                                                cell.avatarImageView?.image = JSQMessagesAvatarImageFactory().circularAvatarImage(image!)
                                            }
        }
        if message.isMediaMessage {
            if (message.imgUrl != nil) {
                SDWebImageManager.shared().loadImage(with: URL(string: message.imgUrl!), options: SDWebImageOptions(rawValue: 0), progress: nil) { image, data, error, cacheType, rtn, imageURL in
                    if (image != nil) {
                        let messageMedia = JSQPhotoMediaItem(image: image)
                        cell.mediaView = messageMedia.mediaView() != nil ? messageMedia.mediaView() : messageMedia.mediaPlaceholderView();
                    }
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        //        if (indexPath.item % 3 == 0) {
        //            let msg = sortedMessages[indexPath.item]
        //            let message = ChatMessage(senderId: msg.author, displayName: msg.author, text: msg.body)
        //            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        //        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        //        if indexPath.item % 3 == 0 {
        //            return kJSQMessagesCollectionViewCellLabelHeightDefault
        //        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        //        let msg = sortedMessages[indexPath.item]
        //        let message = ChatMessage(senderId: msg.author, displayName: msg.author, text: msg.body)
        let message = sortedMessages[indexPath.item]
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return nil
        }
        
        if message.senderId == self.senderId() {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return 0.0
        }
        
        /**
         *  iOS7-style sender name labels
         */
        //        let msg = sortedMessages[indexPath.item]
        //        let currentMessage = ChatMessage(senderId: msg.author, displayName: msg.author, text: msg.body)
        let currentMessage = sortedMessages[indexPath.item]
        
        if currentMessage.senderId == self.senderId() {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            //            let msg = sortedMessages[indexPath.item - 1]
            //            let previousMessage = ChatMessage(senderId: msg.author, displayName: msg.author, text: msg.body)
            let previousMessage = sortedMessages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    //    var messagesTCH:Set<TCHMessage> = Set<TCHMessage>()
    var messagesTCH:Set<ChatMessage> = Set<ChatMessage>()
    var sortedMessages:[ChatMessage]! = []
}

extension ChatVC : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        if (chosenImage == nil) {
            return
        }
        
        let imageData = UIImagePNGRepresentation(chosenImage!)! as Data
        
        let userDefaults = UserDefaults.standard
        let token = userDefaults.string(forKey: UserProfile.token) ?? ""
        picker.dismiss(animated: true) {
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData,
                                             withName: "file",
                                             fileName: "image.jpg",
                                             mimeType: "image/png")
                    multipartFormData.append(token.data(using: .utf8)!, withName: UserProfile.token)
            }, to: UPLOAD_ENDPOINT){ encodingResult  in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        NVActivityIndicatorPresenter.sharedInstance.setMessage(String(format: "%d%%", Int(progress.fractionCompleted * 100)))
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
                                let url = json["image-id"].string!
                                let photoItem = JSQPhotoMediaItem(image: chosenImage)
                                self.addMedia(photoItem, url: url)
                                
                                break
                            }
                        }
                    }
                    break
                case .failure( _):
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    break
                }
            }
        }
    }
    
}
extension ChatVC {
    func sendMessage(inputMessage: ChatMessage) {
        let json = JSON(["command": "chat", "from": getMyUserName(), "msg": inputMessage.text])
        addMessages(newMessages: [inputMessage])
        let message = channel.messages.createMessage(withBody: json.rawString())
        channel.messages.send(message, completion: nil)
    }
    func sendMessage(inputMessage: ChatMessage, url : String) {
        let json = JSON(["command": "image", "from": "user", "image_data": url])
        addMessages(newMessages: [inputMessage])
        let message = channel.messages.createMessage(withBody: json.rawString())
        channel.messages.send(message, completion: nil)
    }
    func addMessages(newMessages:Set<ChatMessage>) {
        messagesTCH =  messagesTCH.union(newMessages)
        sortMessages()
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.collectionView?.layoutIfNeeded()
            self.scrollToBottom(animated: true)
        }
    }
    func sortMessages() {
        sortedMessages = messagesTCH.sorted { a, b in a.date < b.date }
    }
    func loadMessages() {
        sortedMessages.removeAll()
        messagesTCH.removeAll()
        channel.messages.getLastWithCount(100) { (result, items) in
            let jsqItems = items!.map {
                self.convertMsg(msg: $0)
            }
            self.addMessages(newMessages: Set(jsqItems))
        }
    }
    func convertMsg(msg : TCHMessage) -> ChatMessage {
        let json = JSON(parseJSON: msg.body)
        if (json["command"] == JSON.null) {
            return ChatMessage(senderId: msg.author, displayName: msg.author, text: msg.body)
        }
        let command = json["command"].string!
        var author = msg.author!
        var text = msg.body!
        switch command {
        case "chat":
            author = json["from"].string!
            text = json["msg"].string!
            return ChatMessage(senderId: msg.author, displayName: author, text: text)
        case "image":
            author = json["from"].string!
            var urlStr = json["image_data"].string!
            urlStr = urlStr.replacingOccurrences(of: "https://deepreason.com", with: "https://www.deepreason.com")
            let img = SDImageCache.shared().imageFromCache(forKey: urlStr)
            let msg = ChatMessage(senderId: msg.author, displayName: author, media: JSQPhotoMediaItem(image: img))
            msg.imgUrl = urlStr
            return msg
        case "show-feed":
            break
        case "speak-text":
            break
        default:
            break
        }
        return ChatMessage(senderId: msg.author, displayName: author, text: "TestTestTest")
    }
}
extension ChatVC : TCHChannelDelegate {
    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, messageAdded message: TCHMessage!) {
        let msg = convertMsg(msg: message)
        if (msg.senderId != self.senderId()) {
            addMessages(newMessages: [msg])
        }
        //        if !messagesTCH.contains(msg) {
        //            addMessages(newMessages: [msg])
        //        }
    }
    
    //    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, memberJoined member: TCHMember!) {
    ////        addMessages(newMessages: [StatusMessage(member:member, status:.Joined)])
    //    }
    //
    //    func chatClient(_ client: TwilioChatClient!, channel: TCHChannel!, memberLeft member: TCHMember!) {
    ////        addMessages(newMessages: [StatusMessage(member:member, status:.Left)])
    //    }
    
    func chatClient(_ client: TwilioChatClient!, channelDeleted channel: TCHChannel!) {
        DispatchQueue.main.async {
            if channel == self.channel {
//                self.revealViewController().rearViewController.performSegue(withIdentifier: MainChatViewController.TWCOpenGeneralChannelSegue, sender: nil)
            }
        }
    }
    
    func chatClient(_ client: TwilioChatClient!,
                    channel: TCHChannel!,
                    synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        if status == .all {
            loadMessages()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.collectionView?.layoutIfNeeded()
                self.scrollToBottom(animated: true)
            }
        }
    }
}
