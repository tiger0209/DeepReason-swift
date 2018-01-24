//
//  FDFeedCellTableViewCell.swift
//  DeepReason
//
//  Created by Sierra on 7/7/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SDWebImage

class FDFeedHeader: UIView {
    private var iconView = UIImageView()
    private var titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let height = frame.size.height
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        blurView.frame = CGRect.init(x: 0, y: 0, width: screenW, height: height)
//        self.addSubview(blurView)

        iconView.frame = CGRect.init(x: height * 0.1, y: height * 0.1, width: height * 0.8, height: height * 0.8)
        iconView.contentMode = .scaleToFill
        iconView.layer.cornerRadius = height / 2
        iconView.layer.masksToBounds = true
        self.addSubview(iconView)
        
//        titleLabel.frame = CGRect.init(x: height * 1.5, y: 0, width: screenW - height * 1.5, height: height)
        titleLabel.frame = CGRect.init(x: height * 0.5, y: 0, width: screenW - height * 1.5, height: height)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        self.addSubview(titleLabel)
    }
    
    var entity: Feed? {
        didSet {
            titleLabel.text = entity?.title
            iconView.image = nil
//            if let iconUrl = entity?.icon, !iconUrl.isEmpty {
                // FIX CUICatalog: Invalid asset name supplied:
//                iconView.sd_setImage(with: URL(string: iconUrl), placeholderImage: UIImage(named: "placeholder.png"))
//            }
        }
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

