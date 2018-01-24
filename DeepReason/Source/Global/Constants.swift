//
//  Constants.swift
//  DeepReason
//
//  Created by Zeus on 7/30/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import SwiftyJSON


let SIGNUP_ENDPOINT = "http://www.deepreason.com/api/SignupRemoteClient.ashx"
let LOGIN_ENDPOINT = "http://www.deepreason.com/api/AuthenticateRemoteClient.ashx"
let FEED_ENDPOINT = "http://www.deepreason.com/api/GetDynamicFeed.ashx"
let UPLOAD_ENDPOINT = "http://www.deepreason.com/api/UploadFileFrom_RemoteClient.aspx"
let UPLOAD_AVATAR_ENDPOINT = "http://www.deepreason.com/api/UpdateUserProfileImage.aspx"
let PROFILE_ENDPOINT = "http://www.deepreason.com/api/GetUserInfo.ashx"
let LOCATION_ENDPOINT = "http://www.deepreason.com/api/UpdateLocationInfo.ashx"
let CONTACT_ENDPOINT = "http://www.deepreason.com/api/UserInitiatedContactMediation.ashx"
let ACTIVITY_ENDPOINT = "http://www.deepreason.com/api/UserActivityNotification.ashx"

let TOKEN_ENDPOINT = "http://www.deepreason.com/api/GetTwilioCredentials.ashx"

class UserProfile {
    static let firstname = "firstname"
    static let lastname = "lastname"
    static let email = "email"
    static let password = "password"
    static let phone = "phone"
    static let token = "token"
    static let id = "id"
    static let fid = "fid"
    static let accessToken = "accessToken"
    static let icon = "icon"
    
    let first_name : String
    let last_name : String
    let icon : String
    let voice_id : String
    
    init(dict: JSON) {
        first_name = dict["first_name"].string!
        last_name = dict["last_name"].string!
        icon = dict["icon"].string!
        voice_id = dict["voice-id"].string!
    }
    func getName() -> String {
        return "\(first_name) \(last_name)"
    }
}

class Permissions {
    static let location = "location"
    static let contact = "contact"
}
