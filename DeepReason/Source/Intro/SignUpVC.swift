//
//  SignUpVC.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class SignUpVC: UIViewController {
    @IBOutlet weak var firstName: SkyFloatingLabelTextField!
    @IBOutlet weak var lastName: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    
    @IBOutlet weak var itemNext: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // set disable color of next button
        itemNext.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0, green: 0.8, blue: 0.8, alpha: 0.5)], for: .disabled)
        itemNext.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0, green: 0.8, blue: 0.8, alpha: 1.00)], for: .normal)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(firstName.text!, forKey: UserProfile.firstname)
        userDefaults.setValue(lastName.text!, forKey: UserProfile.lastname)
        userDefaults.setValue(email.text!, forKey: UserProfile.email)
        userDefaults.setValue(password.text!, forKey: UserProfile.password)
    }
    
    @IBAction func actionBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func isValidName(firstName:String, lastName:String) -> Bool {
        return firstName.characters.count > 0 && lastName.characters.count > 0
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
    
    @IBAction func onValueUpdate(_ sender: Any) {
        let firstName = self.firstName.text
        let lastName = self.lastName.text
        let email = self.email.text
        let password = self.password.text
        itemNext.isEnabled = isValidEmail(email: email!) && isValidName(firstName: firstName!, lastName: lastName!) && isValidPassword(password: password!)
    }
}
