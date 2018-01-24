import UIKit
import TwilioChatClient
import TwilioAccessManager
import SCLAlertView

class MessagingManager: NSObject {
    
    static let _sharedManager = MessagingManager()
    
    var client:TwilioChatClient?
    var channelMgr:ChannelManager?
    var delegate:MessagingDelegate?
    var connected = false
    var accessManager : TwilioAccessManager?
    
    
    override init() {
        super.init()
        channelMgr = ChannelManager.sharedManager
    }
    
    class func sharedManager() -> MessagingManager {
        return _sharedManager
    }
    func initializeClientWithToken(token: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.accessManager = TwilioAccessManager(token: token, delegate: self)
        TwilioChatClient.chatClient(withToken: token, properties: nil, delegate: self) { [weak self] result, chatClient in
            guard (result?.isSuccessful() ?? false) else { return }
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self?.connected = true
            self?.client = chatClient
            self?.accessManager?.registerClient(chatClient!, forUpdates: { [weak client = self?.client] (token) in
                client?.updateToken(token) { (result) in
                    if (!(result?.isSuccessful())!) {
                        // warn the user the update didn't succeed
                    }
                }
            })
        }
    }
    
    func requestTokenWithCompletion(completion:@escaping (Bool, String?) -> Void) {
        let accessToken = SessiongMgr.fetchToken()
        if accessToken == nil {
            SCLAlertView().showError("Network Error", subTitle: "Please try again later")
            return
        }
        let defaults = UserDefaults.standard
        defaults.setValue(accessToken, forKeyPath: UserProfile.accessToken)
        completion(accessToken != nil, accessToken)
    }
    
    func errorWithDescription(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : description]
        return NSError(domain: "app", code: code, userInfo: userInfo)
    }
}

extension MessagingManager : TwilioChatClientDelegate {
    func chatClient(_ client: TwilioChatClient!, channelAdded channel: TCHChannel!) {
        self.channelMgr?.chatClient(client, channelAdded: channel)
    }
    
    func chatClient(_ client: TwilioChatClient!, channelChanged channel: TCHChannel!) {
        self.channelMgr?.chatClient(client, channelChanged: channel)
    }
    
    func chatClient(_ client: TwilioChatClient!, channelDeleted channel: TCHChannel!) {
        self.channelMgr?.chatClient(client, channelDeleted: channel)
    }
    
    func chatClient(_ client: TwilioChatClient!, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        if status == TCHClientSynchronizationStatus.completed {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            ChannelManager.sharedManager.channelsList = client.channelsList()
            ChannelManager.sharedManager.populateChannels() {
                if (self.delegate == nil) {
                    return
                }
                self.delegate?.finishInitialize!()
            }
        }
        self.channelMgr?.chatClient(client, synchronizationStatusUpdated: status)
    }
}

// MARK: - TwilioAccessManagerDelegate
extension MessagingManager : TwilioAccessManagerDelegate {
    func accessManagerTokenWillExpire(_ accessManager: TwilioAccessManager) {
        requestTokenWithCompletion { succeeded, token in
            if (succeeded) {
                accessManager.updateToken(token!)
            }
            else {
                print("Error while trying to get new access token")
            }
        }
    }
    
    func accessManager(_ accessManager: TwilioAccessManager!, error: Error!) {
        print("Access manager error: \(error.localizedDescription)")
    }
}

@objc protocol MessagingDelegate {
    
    @objc optional func finishInitialize()
    
}
