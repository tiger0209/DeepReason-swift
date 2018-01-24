//
//  ProfileRootVC.swift
//  DeepReason
//
//  Created by Zeus on 8/3/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import Foundation
import UIKit

class TabRootVC: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let status_height : CGFloat = 0
        let frame = self.view.bounds
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let bulrView = UIVisualEffectView(effect: blurEffect)
        bulrView.frame = CGRect.init(x: frame.origin.x, y: frame.origin.y + status_height, width: frame.size.width, height: frame.size.height - status_height)
        bulrView.layer.zPosition = -1000
        bulrView.isUserInteractionEnabled = false
        self.view.addSubview(bulrView)
        
//        let view = UIView()
//        view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 45 + status_height)
//        view.backgroundColor = UIColor.white
//        view.alpha = 0.1
//        view.layer.zPosition = -1000
//        view.isUserInteractionEnabled = false
//        self.view.addSubview(view)
    }
}
