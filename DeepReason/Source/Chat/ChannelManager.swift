import UIKit
import TwilioChatClient

class ChannelManager: NSObject {
    static let sharedManager = ChannelManager()
    
//    weak var delegate:MenuViewController?
    
    var channelsList:TCHChannels?
    var channels:NSMutableOrderedSet?
    var generalChannel:TCHChannel!
    
    override init() {
        super.init()
        channels = NSMutableOrderedSet()
    }
    
    // MARK: - Populate channels
    
    func populateChannels(completion: @escaping () -> Void) {
        channels = NSMutableOrderedSet()
        channelsList?.userChannelDescriptors { result, paginator in
            self.channels?.addObjects(from: paginator!.items())
            self.sortChannels()
            completion()
        }
    }
    
    func sortChannels() {
        let sortSelector = #selector(NSString.localizedCaseInsensitiveCompare(_:))
        let descriptor = NSSortDescriptor(key: "friendlyName", ascending: true, selector: sortSelector)
        channels!.sort(using: [descriptor])
    }
    
    // MARK: - Create channel
    
    func createChannelWithName(name: String, friendly: String, completion: @escaping (Bool, TCHChannel?) -> Void) {
        let channelOptions:[NSObject : AnyObject] = [
            TCHChannelOptionFriendlyName as NSObject: friendly as AnyObject,
            TCHChannelOptionUniqueName as NSObject: name as AnyObject,
            TCHChannelOptionType as NSObject: TCHChannelType.private.rawValue as AnyObject
        ]
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        self.channelsList?.createChannel(options: channelOptions) { result, channel in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false;
            completion((result?.isSuccessful())!, channel)
        }
    }
}

// MARK: - TwilioChatClientDelegate
extension ChannelManager : TwilioChatClientDelegate {
    func chatClient(_ client: TwilioChatClient!, channelAdded channel: TCHChannel!) {
        DispatchQueue.main.async {
            if self.channels != nil {
                self.channels!.add(channel)
                self.sortChannels()
            }
//            self.delegate?.chatClient(client, channelAdded: channel)
        }
    }
    
    func chatClient(_ client: TwilioChatClient!, channelChanged channel: TCHChannel!) {
//        self.delegate?.chatClient(client, channelChanged: channel)
    }
    
    func chatClient(_ client: TwilioChatClient!, channelDeleted channel: TCHChannel!) {
        DispatchQueue.main.async {
            if self.channels != nil {
                self.channels?.remove(channel)
            }
//            self.delegate?.chatClient(client, channelDeleted: channel)
        }
        
    }
    
    func chatClient(_ client: TwilioChatClient!, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
    }
}
