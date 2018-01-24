//
//  FDFeedEntity.swift
//  DeepReason
//
//  Created by Sierra on 7/7/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import SwiftyJSON

struct Feed {
    let voice_id : String!
    let images : [String]!
    let user_name : String!
    let title : String!
    let user_icon : String!
    let time : String!
    let media_type: String!

    let feed_item_id : String!
    let body : String!
    let location : String!
    
    let voice_chat : Bool!
    let text_chat : Bool!
    let contact_chat : Bool!

    var alive = true
    init(dict: [String: JSON]) {
        voice_id = dict["voice-id"]?.string
//        voice_id = "dr_b5908ae4ce0641dc81251a4f9e2f6f23"
        let _images = dict["image"]?.array

        images = _images?.map({$0.string!})
        user_name = dict["user-name"]?.string
        title = dict["title"]?.string
        user_icon = dict["user-icon"]?.string
        media_type = dict["media-type"]?.string
        let str = dict["time"]?.string
        let index = str!.index(str!.startIndex, offsetBy: 9)
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd"
        let date = RFC3339DateFormatter.date(from: str!.substring(to: index))
        RFC3339DateFormatter.dateFormat = "MMMM dd, yyyy"
        time = RFC3339DateFormatter.string(from: date!)

        feed_item_id = dict["feed-item-id"]?.string
        body = dict["body"]?.string
        location = dict["location"]?.string

        text_chat = dict["text-chat"]?.bool
        voice_chat = dict["voice-chat"]?.bool
        contact_chat = dict["contact-chat"]?.bool
    }
}
