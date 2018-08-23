////
////  Video.swift
////  Nuke
////
////  Created by Owen Campbell on 2018-08-22.
////  Copyright © 2018 Owen Campbell. All rights reserved.
////
//
//import Foundation
//
//struct Video: Codable, CustomStringConvertible
//{
//    var deck: String
//    var videoUrls: [VideoQuality: URL]
//    var guid: String
//    var id: Int
//    var images: [ImageQuality: URL]
//    var length: TimeInterval
//    var name: String
//    var date: String
//    var siteUrl: URL
//    var author: String
//    var show: Show?
//    var categories: [Category]
//    var savedTime: TimeInterval?
//    var youtubeId: String?
//
//    init(from videoResponse: VideoResponse) {
//        deck = videoResponse.deck
//        videoUrls = [
//            .hd: videoResponse.hd_url,
//            .high: videoResponse.high_url,
//            .low: videoResponse.low_url
//        ]
//        guid = videoResponse.guid
//        id = videoResponse.id
//        images = [
//            .icon: videoResponse.images.icon,
//            .medium: videoResponse.images.icon,
//            .screen: videoResponse.images.icon,
//            .screenLarge: videoResponse.images.icon,
//            .icon: videoResponse.images.icon,
//            .icon: videoResponse.images.icon,
//            .icon: videoResponse.images.icon,
//            .icon: videoResponse.images.icon,
//        ]
//    }
//    
////    case icon = "icon_url"
////    case medium = "medium_url"
////    case screen = "screen_url"
////    case screenLarge = "screen_large_url"
////    case small = "small_url"
////    case large = "super_url"
////    case thumb = "thumb_url"
////    case tiny = "tiny_url"
////    case original = "original_url"
//    
//    var description: String {
//        let noshow = "No Show"
//        return "\(name) - \(date) - \(categories) - \(show?.description ?? noshow)"
//    }
//    
//}
