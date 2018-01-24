//
//  IntroVC.swift
//  DeepReason
//
//  Created by Zeus on 8/13/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SwiftyGif

class IntroVC: UIViewController, SwiftyGifDelegate {
    @IBOutlet weak var imgGit: UIImageView!
    @IBInspectable var pathGit : String = ""
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var currentIndex = 0
    var gifArray = ["ad-1", "ad-1-1", "ad-1-2"]
    var isBottom = false
    let gifManager = SwiftyGifManager(memoryLimit:20)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgGit.animationManager = gifManager
        if isBottom {
            bottomConstraint.constant = 0
        }
        let gif = UIImage(gifName: pathGit)
        imgGit.setGifImage(gif, manager: gifManager)
        stopAnim()
        imgGit.startAnimatingGif()
        startAnim()
        if pathGit == "ad-1" {
            imgGit.delegate = self
        }
    }
    func startAnim() {
        imgGit.showFrameAtIndex(0)
    }
    func stopAnim() {
        imgGit.stopAnimatingGif()
    }
    func setBottom() {
        isBottom = true
    }
    func gifDidLoop() {
        currentIndex += 1;
        if currentIndex > 2 {
            currentIndex = 0
        }
        let gif = UIImage(gifName: gifArray[currentIndex])
        imgGit.setGifImage(gif, manager: gifManager)
        stopAnim()
        imgGit.startAnimatingGif()
    }

}
