//
//  MasterIntroVC.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import BWWalkthrough

class MasterIntroVC: BWWalkthroughViewController, BWWalkthroughViewControllerDelegate {
    var intro : [IntroVC]?

    func gotoMain() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "main")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let token = UserDefaults.standard.string(forKey: UserProfile.token) ?? ""
        if token != "" {
            self.gotoMain()
            return
        }

        //init intro items
        let sb = UIStoryboard(name: "Intro", bundle: nil)
        let intro1 = sb.instantiateViewController(withIdentifier: "intro1") as! IntroVC;
        let intro2 = sb.instantiateViewController(withIdentifier: "intro2") as! IntroVC;
        let intro3 = sb.instantiateViewController(withIdentifier: "intro3") as! IntroVC;
        let intro4 = sb.instantiateViewController(withIdentifier: "intro4") as! IntroVC;
        let intro5 = sb.instantiateViewController(withIdentifier: "intro5") as! IntroVC;
        let intro6 = sb.instantiateViewController(withIdentifier: "intro6") as! IntroVC;
        let intro7 = sb.instantiateViewController(withIdentifier: "intro7") as! IntroVC;
        let intro8 = sb.instantiateViewController(withIdentifier: "intro8") as! IntroVC;
        let intro9 = sb.instantiateViewController(withIdentifier: "intro9") as! IntroVC;
        self.add(viewController: intro1);
        self.add(viewController: intro2);
        self.add(viewController: intro3);
        self.add(viewController: intro4);
        self.add(viewController: intro5);
        self.add(viewController: intro6);
        self.add(viewController: intro7);
        self.add(viewController: intro8);
        self.add(viewController: intro9);
        intro = [intro1, intro2, intro3, intro4, intro5, intro6, intro7, intro8, intro9]
        self.delegate = self
        
        //make background of navigation bar transparent
        let navigationBar = self.navigationController!.navigationBar
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true

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
        intro?[pageNumber].startAnim()
    }
}
