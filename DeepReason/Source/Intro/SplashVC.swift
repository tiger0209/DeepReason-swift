
//  SplashVC.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import Alamofire

class SplashVC: UIViewController {
    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.isHidden = true
        self.loading()
    }

    private func anim() {
        logoView.alpha = 0.3
        UIView.animate(withDuration: 3.0, animations: {
            self.logoView.alpha = 1.0
        }) { (Bool) in
            guard UserDefaults.standard.string(forKey: UserProfile.token) != nil else {
                self.gotoLogin()
                return
            }
            self.gotoMain()
        }
    }
    private func loading () {
        logoView.isHidden = false
        self.anim()
    }
    private func gotoLogin() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Intro", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "login")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func gotoMain() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "main")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
