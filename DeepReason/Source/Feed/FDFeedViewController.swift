//
//  FirstTableViewController.swift
//  DeepReason
//
//  Created by Sierra on 7/7/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SDWebImage

class FDFeedViewController: UIViewController {
    var feeds: [Feed] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FDFeedCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.navigationController?.isToolbarHidden = true
//        tableView.fd_debugLogEnabled = true
        tableView.separatorStyle = .none
        //navigation bar gradient background
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 64/255, green: 147/255, blue: 147/255, alpha: 0.5)
        let userDefaults = UserDefaults.standard
        let token = userDefaults.string(forKey: UserProfile.token) ?? ""
        let fid = userDefaults.string(forKey: UserProfile.fid) ?? ""
        let param : Parameters = [
            UserProfile.token: token,
            UserProfile.fid: fid
        ]
        
        Alamofire.request(FEED_ENDPOINT, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { response in
            print(response.result.value)
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
                    let feeds = json["feed"].array!
                    self.feeds = feeds.map { Feed(dict: $0.dictionaryValue) }
                    self.tableView.reloadData()
                    break
                }
            }
        }
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
        
        self.title = "Feed"
    }

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let cell = cell as? FDFeedCell
//        cell?.fd_usingFrameLayout = true // Enable to use "-sizeThatFits:"
        cell?.accessoryType = .none
        cell?.setEntity(feed: feeds[indexPath.section], indexPath: indexPath)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CallVC.instance = nil
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func removeFeed(index: IndexPath) {
        self.feeds[index.section].alive = false
        self.tableView.reloadData()
    }
    
    func goToChat() {
        let childVC = self.storyboard?.instantiateViewController(withIdentifier: "chat")
        self.navigationController?.pushViewController(childVC!, animated: true)
    }
}
extension FDFeedViewController: UITableViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let rows = self.tableView.indexPathsForVisibleRows
//        if (rows?.count == 0) {
//            return
//        }
//        
//        for i in 0...tableView.numberOfSections - 1 {
//            for j in 0...tableView.numberOfRows(inSection: i) - 1 {
//                let indexPath = IndexPath(row: j, section: i)
//                if let cell = tableView.cellForRow(at: indexPath) {
//                    var rectCell = tableView.rectForRow(at: indexPath)
//                    let rectSection = tableView.rectForHeader(inSection: i)
//                    let offsetHeight = tableView.contentOffset.y + 64
//                    rectCell = rectCell.offsetBy(dx: -tableView.contentOffset.x, dy: -offsetHeight)
//                    let fdCell = cell as! FDFeedCell
//                    fdCell.setHidenHeight(height: CGFloat(rectSection.size.height - rectCell.origin.y))
//                }
//            }
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "feed_details") as! FeedDetailVC
        detailVC.feed = feeds[indexPath.section]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension FDFeedViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        if (feeds.count == 0) {
            return 0
        }
        return feeds.count
    }
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let cell = _cell as? FDFeedCell
        cell?.setTableViewVC(vc: self)
        configure(cell: cell!, at: indexPath)
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if feeds[indexPath.section].alive == false {
            return 0;
        }
        let feed = feeds[indexPath.section]
        let img = SDImageCache.shared().imageFromCache(forKey: feed.images[0])
        if (img == nil) {
            return 200
        }
        var height = CGFloat(48 + 32)//button + margin
        let width = UIScreen.main.bounds.size.width
        let padding = CGFloat(width > 330 ? 64 : 32)
        let imgW = img?.size.width
        let imgH = img?.size.height
        height += (imgH! / imgW! * (width - padding))
        let tmpLabel = UILabel()
        tmpLabel.numberOfLines = 0
        tmpLabel.lineBreakMode = .byWordWrapping
        tmpLabel.frame = CGRect(x: 0, y: 0, width: width - padding, height: 0)
        tmpLabel.font = UIFont.systemFont(ofSize: 16.0)
        tmpLabel.text = feed.body
        tmpLabel.sizeToFit()
        height += tmpLabel.frame.size.height
        tmpLabel.font = UIFont.systemFont(ofSize: 12.0)
        tmpLabel.text = feed.location
        tmpLabel.sizeToFit()
        height += (tmpLabel.frame.size.height)
        tmpLabel.text = feed.title
        tmpLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        tmpLabel.frame = CGRect(x: 0, y: 0, width: width - 56 - padding, height: 0)
        tmpLabel.sizeToFit()
        height += (tmpLabel.frame.size.height)
        return height
    }
    
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return String.init(format: "Section %d", section)
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = FDFeedHeader(frame: CGRect(x: 0, y: 0, width: screenW, height: 40))
//        header.entity = feeds[section]
//        return header
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40.0
//    }
}

//extension UINavigationBar {
//
//    func setGradientBackground(colors: [UIColor]) {
//
//        var updatedFrame = bounds
//        updatedFrame.size.height += 20
//        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
//
//        setBackgroundImage(gradientLayer.creatGradientImage(), for: UIBarMetrics.default)
//    }
//}

//extension CAGradientLayer {
//    
//    convenience init(frame: CGRect, colors: [UIColor]) {
//        self.init()
//        self.frame = frame
//        self.colors = []
//        for color in colors {
//            self.colors?.append(color.cgColor)
//        }
//        startPoint = CGPoint(x: 0, y: 0)
//        endPoint = CGPoint(x: 0, y: 1)
//    }
//    
//    func creatGradientImage() -> UIImage? {
//        
//        var image: UIImage? = nil
//        UIGraphicsBeginImageContext(bounds.size)
//        if let context = UIGraphicsGetCurrentContext() {
//            render(in: context)
//            image = UIGraphicsGetImageFromCurrentImageContext()
//        }
//        UIGraphicsEndImageContext()
//        return image
//    }
//}
