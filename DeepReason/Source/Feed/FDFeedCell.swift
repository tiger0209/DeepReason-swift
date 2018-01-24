//
//  FDFeedCell.swift
//  DeepReason
//
//  Created by Sierra on 7/7/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SDWebImage
import Koloda
import pop
import Alamofire
import SwiftyJSON
import AVFoundation

let screenW = UIScreen.main.bounds.width

private let kolodaCountOfVisibleCards = 1
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class FDFeedCell: UITableViewCell {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var kolodaView: KolodaView!
    
    var startLocation : CGPoint? = nil

    var feedVC: FDFeedViewController?
    public var indexPath: IndexPath?
    public var blurLayer = UIVisualEffectView()

    var feed: Feed? {
        didSet {
            kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
            kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
            kolodaView.delegate = self
            kolodaView.dataSource = self

            self.isUserInteractionEnabled = true

            let swipeRight = UISwipeGestureRecognizer();
            swipeRight.direction = .right
            swipeRight.addTarget(self, action: #selector(self.actionSwipe(swipeGesture:)))

            let swipeLeft = UISwipeGestureRecognizer();
            swipeLeft.direction = .left
            swipeLeft.addTarget(self, action: #selector(self.actionSwipe(swipeGesture:)))

            self.addGestureRecognizer(swipeRight)
            self.addGestureRecognizer(swipeLeft)
            
            let tap = UITapGestureRecognizer();
            tap.addTarget(self, action: #selector(self.actionTap(tapGesture:)))
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(tap)
            self.selectionStyle = .none
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
//    func calcHeight() ->CGFloat {
//        guard let card = kolodaView.viewForCard(at: 0) as? FeedCell else {
//            return 0
//        }
//        var totalHeight: CGFloat = 0
//        totalHeight += (8 * 5) // margins
//        totalHeight += 30 // button
//        if (kolodaView.countOfCards == 0) {
//            totalHeight += 200;
//            return totalHeight
//        }
//        totalHeight += card.lblContent.sizeThatFits(self.frame.size).height
//        totalHeight += card.lblName.sizeThatFits(self.frame.size).height
//        let imgSize = card.imgBG.sizeThatFits(self.frame.size)
//        var imgHeight = imgSize.height
//        let imgWidth = imgSize.width
//        if (imgWidth > 300) {
//            imgHeight = imgHeight * 300 / imgWidth
//        }
//        totalHeight += imgHeight
//        if (imgHeight == 0) {
//            totalHeight += 400
//        }
//        return totalHeight
//    }
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        guard let card = kolodaView.viewForCard(at: 0) as? FeedCell else {
//            return CGSize(width: screenW, height: 0)
//        }
//        var totalHeight: CGFloat = 0
//        totalHeight += card.lblContent.sizeThatFits(size).height
//        totalHeight += card.lblName.sizeThatFits(size).height
//        if (kolodaView.countOfCards == 0) {
//            totalHeight = 200
//            return CGSize(width: screenW, height: totalHeight)
//        }
//        let imgSize = card.imgBG.sizeThatFits(size)
//        var imgHeight = imgSize.height
//        let imgWidth = imgSize.width
//        if (imgWidth > 300) {
//            imgHeight = imgHeight * 300 / imgWidth
//        }
//        totalHeight += imgHeight
//        if (imgHeight == 0) {
//            totalHeight += 400
//        }
//        totalHeight += (8 * 5) // margins
//        totalHeight += 30 // button
//        return CGSize(width: screenW, height: totalHeight)
//    }
}

extension FDFeedCell {
    func actionTap(tapGesture: UITapGestureRecognizer) {
        print ("tap")
    }
    func actionSwipe(swipeGesture: UISwipeGestureRecognizer) {
//        if (swipeGesture.state == .began) {
//            startLocation = swipeGesture.location(in: self);
//        }
//        else if (swipeGesture.state == .ended) {
//            let stopLocation = swipeGesture.location(in: self);
//            if (startLocation == nil) {
//                startLocation = stopLocation
//                return
//            }
//            let dx = stopLocation.x - startLocation!.x;
//            let dy = stopLocation.y - startLocation!.y;
//            let distance = sqrt(dx*dx + dy*dy );
//            NSLog("Distance: %f", distance);
//            if distance > 10 {
//                startLocation = nil
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.right:
                    self.kolodaView.swipe(.right)
                case UISwipeGestureRecognizerDirection.left:
                    self.kolodaView.swipe(.left)
                default:
                    break
                }
//            }
//        }
    }
}
extension FDFeedCell {
    func gotoChat(uniqeName: String, targetName: String) {
        UserDefaults.standard.setValue(uniqeName, forKeyPath: CallID.channel)
        UserDefaults.standard.setValue(targetName, forKeyPath: CallID.chat_name)
        UserDefaults.standard.setValue((feed?.user_icon)!, forKeyPath: CallID.icon)
        self.feedVC?.goToChat()
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
    func setTableViewVC(vc: FDFeedViewController) {
        self.feedVC = vc
    }
    func setEntity(feed: Feed?, indexPath: IndexPath) {
        self.indexPath = indexPath
        if (self.feed?.feed_item_id! != feed?.feed_item_id!) {
            self.feed = feed
            self.kolodaView.resetCurrentCardIndex()
        }
    }

    func getTableView() -> UITableView? {
        var view = self.superview
        while ((view != nil) && view?.isKind(of: UITableView.classForCoder()) == false) {
            view = view?.superview;
        }
        return view as? UITableView;
    }

    func setHidenHeight(height: CGFloat) {
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(width: self.frame.width, height: self.frame.height, diff: height).cgPath
        self.kolodaView.layer.mask = mask
    }
}

extension String {
    var length: Int {
        return characters.count
    }
}

extension UIBezierPath {
    convenience init(width: CGFloat, height: CGFloat, diff: CGFloat) {
        self.init()
        move(to: CGPoint.init(x: 0, y: diff))
        addLine(to: CGPoint(x: 0, y: height))
        addLine(to: CGPoint(x: width, y: height))
        addLine(to: CGPoint(x: width, y: diff))
        close()
    }
}
extension FDFeedCell: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int ) -> Bool {
        return false;
    }

    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.feedVC?.removeFeed(index: self.indexPath!)
        }
    }
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {

    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldMoveBackgroundCard(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
}

// MARK: KolodaViewDataSource
extension FDFeedCell: KolodaViewDataSource {
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 1
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let feedCell = Bundle.main.loadNibNamed("FeedCell", owner: self, options: nil)?[0] as! FeedCell
        let width = UIScreen.main.bounds.size.width
        let padding = CGFloat(width > 330 ? 64 : 32)
        feedCell.marginWidth.constant = -padding
        feedCell.cell = self
        feedCell.icon.sd_setImage(with: URL(string: feed!.user_icon))
        let media_type = feed?.media_type
        if media_type == "image" {
            feedCell.imgBG.sd_setImage(with: URL(string: feed!.images[0]), placeholderImage: UIImage(named: "placeholder.png"), options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                let tableView = self.getTableView();
                self.bgImageView.image = image
                if (cacheType != .none) {
                    return
                }
                if (tableView != nil) {
                    tableView?.reloadRows(at: [self.indexPath!], with: .none)
                }
            })
        } else if (media_type == "video") {
            let url = URL(string: feed!.images[0])
            if let thumbnailImage = getThumbnailImage(forUrl: url!) {
                feedCell.imgBG.image = thumbnailImage
                self.bgImageView.image = thumbnailImage
                let tableView = self.getTableView();
                if (tableView != nil) {
                    tableView?.reloadRows(at: [self.indexPath!], with: .none)
                }
            }
        } else {
            
        }
        feedCell.lblTitle.text = feed?.title
        feedCell.lblLocation.text = feed?.location
        feedCell.lblTime.text = feed?.time
        feedCell.lblBody.text = feed?.body
        feedCell.btnCall.isHidden = !feed!.voice_chat
        feedCell.btnChat.isHidden = !feed!.text_chat
        feedCell.btnContact.isHidden = !feed!.contact_chat
        feedCell.updateConstraints()
        
        feedCell.btnCall.setType(.default)
        feedCell.btnChat.setType(.default)
        feedCell.btnContact.setType(.default)
        return feedCell
    }
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(10, 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
