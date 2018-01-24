//
//  ProfileVC.swift
//  DeepReason
//
//  Created by Sierra on 7/8/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON
import SDWebImage
import SCLAlertView

class ProfileVC: UIViewController {//, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public var itemFrame: CGRect?
//    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var bulrView: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // set navigation bar transparent
//        let navigationBar = self.navigationController!.navigationBar
//        navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationBar.shadowImage = UIImage()
//        navigationBar.isTranslucent = true
       
        //set avatar gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectAvatar))
        avatarView.addGestureRecognizer(tapGesture)
        avatarView.isUserInteractionEnabled = true
        
        let icon = UserDefaults.standard.string(forKey: UserProfile.icon)!
        avatarView.sd_setImage(with: URL(string: icon), placeholderImage: UIImage(named: "avatar_add_round"))
    }

    func actionUpdate() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())

        let imageData = avatarView.image?.generatePNGRepresentation()
        let userDefaults = UserDefaults.standard
        let token = userDefaults.string(forKey: UserProfile.token) ?? ""
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!,
                                         withName: "file",
                                         fileName: "image.jpg",
                                         mimeType: "image/png")
                multipartFormData.append(token.data(using: .utf8)!, withName: UserProfile.token)
        }, to: UPLOAD_AVATAR_ENDPOINT){ encodingResult  in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress { progress in
                    NVActivityIndicatorPresenter.sharedInstance.setMessage(String(format: "%d%%", Int(progress.fractionCompleted * 100)))
                }
                upload.validate()
                upload.responseJSON { response in
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
                            print(reason)
                            return
                        default:
                            let url = json["image-id"].string!
                            userDefaults.set(url, forKey: UserProfile.icon)
                            SCLAlertView().showSuccess("Profile", subTitle: "Update Successfully")
                            break
                        }
                    }
                }
                break
            case .failure( _):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                break
            }
        }
    }
    
    @IBAction func actionTutorial(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Intro", bundle: Bundle.main);
        let intro = storyboard.instantiateViewController(withIdentifier: "tutorial")
        self.navigationController?.pushViewController(intro, animated: true)
    }
    @IBAction func actioncContactUS(_ sender: Any) {
        let url = URL(string: "http://www.deepreason.com/Help.aspx")!
        UIApplication.shared.openURL(url)

    }
    @IBAction func actionLogout(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: UserProfile.firstname)
        UserDefaults.standard.removeObject(forKey: UserProfile.lastname)
        UserDefaults.standard.removeObject(forKey: UserProfile.email)
        UserDefaults.standard.removeObject(forKey: UserProfile.password)
        UserDefaults.standard.removeObject(forKey: UserProfile.phone)
        UserDefaults.standard.removeObject(forKey: UserProfile.token)
        UserDefaults.standard.removeObject(forKey: UserProfile.id)
        UserDefaults.standard.removeObject(forKey: UserProfile.fid)
        UserDefaults.standard.removeObject(forKey: UserProfile.accessToken)
        UserDefaults.standard.removeObject(forKey: UserProfile.icon)

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Intro", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "login")
        self.navigationController?.popToRootViewController(animated: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = viewController

    }
    func selectAvatar(gesture: UIGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        self.present(imagePickerController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBOutlet weak var avatarView: UIImageView!
}

extension UIBezierPath {
    convenience init(width: CGFloat, height: CGFloat, diffHeight: CGFloat, x : CGFloat) {
        self.init()
        move(to: CGPoint(x: 0, y: diffHeight))
        addLine(to: CGPoint(x: 0, y: height))
        addLine(to: CGPoint(x: width, y: height))
        addLine(to: CGPoint(x: width, y: diffHeight))
        addLine(to: CGPoint(x: x + diffHeight * 0.3, y: diffHeight))
        addLine(to: CGPoint(x: x, y: diffHeight * 0.5))
        addLine(to: CGPoint(x: x - diffHeight * 0.3, y: diffHeight))
        close()
    }
}

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage;
        avatarView.image = cameraImage
        picker.dismiss(animated: true) {
            self.actionUpdate()
        }
    }
}
extension UIImage {
    func generatePNGRepresentation() -> Data {
        
        let newImage = self.copyOriginalImage()
        let newData = UIImageJPEGRepresentation(newImage, 0.75)
        
        return newData!
    }
    
    private func copyOriginalImage() -> UIImage {
        UIGraphicsBeginImageContext(self.size);
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return newImage!
    }
}
