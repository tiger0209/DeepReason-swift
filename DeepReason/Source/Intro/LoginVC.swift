//
//  LoginVC.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView

class LoginVC: UIViewController {
    @IBOutlet weak var itemDone: UIBarButtonItem!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set done button
        itemDone.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0, green: 0.8, blue: 0.8, alpha: 0.5)], for: .disabled)
        itemDone.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0, green: 0.8, blue: 0.8, alpha: 1.00)], for: .normal)
        // Do any additional setup after loading the view.
        
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
    @IBAction func actionBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func isValidEmail(email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func isValidPassword(password:String) -> Bool {
        return password.characters.count >= 6
    }

    @IBAction func actionEdit(_ sender: Any) {
        itemDone.isEnabled = isValidEmail(email: self.email.text!) && isValidPassword(password: self.password.text!)
    }

    @IBAction func actionDone(_ sender: Any) {
        self.email.endEditing(true)
        self.password.endEditing(true)
        
        let email = self.email.text!
        let password = self.password.text!
        let param : Parameters = [
            UserProfile.email: email,
            UserProfile.password: password,
        ]
        Alamofire.request(LOGIN_ENDPOINT, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { response in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            switch response.result {
            case .failure(let _):
                SCLAlertView().showWarning("Login Failed", subTitle: "Server Error")
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
                    SCLAlertView().showWarning("Login Failed", subTitle: reason)
                    print(reason)
                    return
                default:
                    let token = json["token"].string!
                    let user_id = json["voice-id"].string!
                    self.getProfile(token: token, user_id: user_id)
                    break
                }
            }
        }
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
    }
    func getProfile(token: String, user_id: String) {
        let param : Parameters = [
            UserProfile.token: token,
            UserProfile.id: user_id,
        ]
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        Alamofire.request(PROFILE_ENDPOINT, method: .get, parameters: param, encoding: URLEncoding.default).responseJSON { response in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            switch response.result {
            case .failure(let _):
                SCLAlertView().showWarning("Login Failed", subTitle: "Server Error")
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
                    SCLAlertView().showWarning("Login Failed", subTitle: reason)
                    print(reason)
                    return
                default:
                    let profile = UserProfile(dict: json)
                    let defaults = UserDefaults.standard
                    defaults.set(profile.first_name, forKey: UserProfile.firstname)
                    defaults.set(profile.last_name, forKey: UserProfile.lastname)
                    defaults.set(profile.icon, forKey: UserProfile.icon)
                    SessiongMgr.login(token: token, user_id: user_id)
                    self.gotoMain()
                    break
                }
            }
        }
    }
    func gotoMain() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "main")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController
    }
}
