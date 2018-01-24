//
//  SessiongMgr.swift
//  DeepReason
//
//  Created by Zeus on 7/30/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SwiftyJSON

class SessiongMgr {
    static public func login(token : String, user_id : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(token, forKeyPath: UserProfile.token)
        userDefaults.setValue(user_id, forKeyPath: UserProfile.id)
    }
    static public func postDataFrom(params:[String:String]) -> String {
        var data = ""
        for (key, value) in params {
            if let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                if !data.isEmpty {
                    data = data + "&"
                }
                data = data + encodedKey + "=" + encodedValue;
            }
        }
        return data
    }
    
    static public func fetchToken() -> String? {
        let device = UIDevice.current.identifierForVendor!.uuidString
        let identity = UserDefaults.standard.string(forKey: UserProfile.id) ?? ""
        let subUrl = postDataFrom(params: ["device": device, "identity": identity])
        guard let accessTokenURL = URL(string: TOKEN_ENDPOINT + "?" + subUrl) else {
            return nil
        }
        let result = try? String(contentsOf: accessTokenURL, encoding: .utf8)
        if result == nil {
            return nil
        }
        let json = JSON(parseJSON: result!)
        if json["status"].string == "ok" {
            return json["token"].string;
        }
        return nil
    }
}
