//
//  MasterIntroVC.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import BWWalkthrough

class TutorialVC: BWWalkthroughViewController, BWWalkthroughViewControllerDelegate {
    var introVCs : [IntroVC]?

    func gotoMain() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "main")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //init intro items
        let sb = UIStoryboard(name: "Intro", bundle: nil)
        let introNames = ["intro1", "intro2", "intro3", "intro4", "intro5", "intro6", "intro7", "intro8", "intro9"]
        for introName in introNames {
            let intro = sb.instantiateViewController(withIdentifier: introName) as! IntroVC;
            intro.setBottom()
            self.add(viewController: intro);
            introVCs?.append(intro)
        }
        self.delegate = self
        
        //make background of navigation bar transparent
        scrollview.bounces = false;
        self.automaticallyAdjustsScrollViewInsets = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // Called when current page changes
    func walkthroughPageDidChange(_ pageNumber:Int) {
        introVCs?[pageNumber].startAnim()
    }
}
