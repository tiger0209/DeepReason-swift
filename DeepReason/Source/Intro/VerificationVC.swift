//
//  VerificationVC.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FontAwesome_swift
import SWFrameButton
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import SCLAlertView

class VerificationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtPhone: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet weak var itemNext: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
//        get telephone code of current local
//        let info = CTTelephonyNetworkInfo();
//        let carrier = info.subscriberCellularProvider;
//        print(carrier?.mobileCountryCode);
        //set phone icon on the text field
        txtPhone.iconFont = UIFont.fontAwesome(ofSize: 30)
        txtPhone.iconText = String.fontAwesomeIcon(name: .mobile)

        //set next button
        itemNext.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0)], for: .disabled)
        itemNext.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0, green: 0.8, blue: 0.8, alpha: 1.0)], for: .normal)

        //setupClear Button
        let btnClear = SWFrameButton()
        btnClear.setTitle("\u{2715}", for: .normal)
        btnClear.tintColor = UIColor(white: 1, alpha: 1);
        btnClear.frame = CGRect(x:0, y:20, width:20, height: 20)
        btnClear.titleLabel?.textAlignment = .center
        btnClear.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        btnClear.cornerRadius = 10
        btnClear.addTarget(self, action: #selector(onClear), for: .touchUpInside);
        txtPhone.rightView = btnClear
        txtPhone.rightViewRect(forBounds:  CGRect(x:0, y:20, width:20, height: 20));
        txtPhone.rightViewMode = .always;
//        Do any additional setup after loading the view.
    }

    func onClear(_ sender: UIButton) {
        txtPhone.text = "+1"
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

    @IBAction func actionEdit(_ sender: Any) {
        let phone = self.txtPhone.text
        let emailRegEx = "^\\+\\d{10,}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        itemNext.isEnabled = emailTest.evaluate(with: phone)
    }
    @IBAction func actionBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func actionNext(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        let firstname = userDefaults.string(forKey: UserProfile.firstname) ?? ""
        let lastname = userDefaults.string(forKey: UserProfile.lastname) ?? ""
        let email = userDefaults.string(forKey: UserProfile.email) ?? ""
        let password = userDefaults.string(forKey: UserProfile.password) ?? ""
        let param : Parameters = [
            UserProfile.firstname: firstname,
            UserProfile.lastname: lastname,
            UserProfile.email: email,
            UserProfile.password: password,
            UserProfile.phone: txtPhone.text!
        ]
        Alamofire.request(SIGNUP_ENDPOINT, method: .post, parameters: param, encoding: URLEncoding.default).responseJSON { response in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
                    SCLAlertView().showWarning("Register Failed", subTitle: reason)
                    return
                default:
                    let token = json["token"].string!
                    let user_id = json["voice-id"].string!
                    SessiongMgr.login(token: token, user_id: user_id)
                    self.getProfile(token: token, user_id: user_id)
                    break
                }
            } else {
                SCLAlertView().showWarning("Register Failed", subTitle: "Server Error")
            }
        }
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let limit = 20;
        if (textField.text!.characters.count > limit && string.characters.count > range.length) {
            return false
        }
        return true
    }
    func gotoMain() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "main")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController
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
}

