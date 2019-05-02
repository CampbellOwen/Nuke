//
//  Video.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

enum VideoQuality: String, Codable {
    case hd
    case high
    case low
}

enum ImageQuality: String, Codable {
    case icon = "icon_url"
    case medium = "medium_url"
    case screen = "screen_url"
    case screenLarge = "screen_large_url"
    case small = "small_url"
    case large = "super_url"
    case thumb = "thumb_url"
    case tiny = "tiny_url"
    case original = "original_url"
}

struct Images: Codable
{
    
    var icon: URL?
    var medium : URL?
    var screen: URL?
    var screenLarge: URL?
    var small: URL?
    var large: URL?
    var thumb: URL?
    var tiny: URL?
    var original: URL?
    var tags: String?
    
    enum CodingKeys: String, CodingKey {
        case icon = "icon_url"
        case medium = "medium_url"
        case screen = "screen_url"
        case screenLarge = "screen_large_url"
        case small = "small_url"
        case large = "super_url"
        case thumb = "thumb_url"
        case tiny = "tiny_url"
        case original = "original_url"
        case tags = "image_tags"
    }
}

struct Video: Decodable, CustomStringConvertible
{
    var deck: String
    var urls: [VideoQuality: URL?]
    var guid: String
    var id: Int
    var images: [ImageQuality: URL]
    var length: TimeInterval
    var name: String
    var date: String
    var siteUrl: URL
    var author: String?
    var show: Show?
    var categories: [Category]
    var savedTime: String?
    var youtubeId: String?
    
    enum CodingKeys: String, CodingKey {
        case deck
        case hd_url
        case high_url
        case low_url
        case guid
        case id
        case images = "image"
        case length = "length_seconds"
        case name
        case date = "publish_date"
        case siteUrl = "site_detail_url"
        case author = "user"
        case show = "video_show"
        case categories = "video_categories"
        case savedTime = "saved_time"
        case youtubeId = "youtube_id"
    }
    
    var description: String {
        let noshow = "No Show"
        return "\(name) - \(date) - \(categories) - \(show?.description ?? noshow)"
    }
    
}

extension Video {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let deck = try container.decode(String.self, forKey: .deck)
        
        let high_url = try? container.decode(URL.self, forKey: .high_url)
        let hd_url = try? container.decode(URL.self, forKey: .hd_url)
        let low_url = try? container.decode(URL.self, forKey: .low_url)
        let urls: [VideoQuality: URL?] = [ .hd: hd_url, .high: high_url, .low: low_url]
        
        let guid = try container.decode(String.self, forKey: .guid)
        let id = try container.decode(Int.self, forKey: .id)
        
        let images = try container.decode(Images.self, forKey: .images)
        var imagesDict = [ImageQuality:URL]()
        if let icon = images.icon {
            imagesDict[.icon] = icon
        }
        if let medium = images.medium {
            imagesDict[.medium] = medium
        }
        if let screen = images.screen {
            imagesDict[.screen] = screen
        }
        if let screenLarge = images.screenLarge {
            imagesDict[.screenLarge] = screenLarge
        }
        if let large = images.large {
            imagesDict[.large] = large
        }
        if let original = images.original {
            imagesDict[.original] = original
        }
        if let small = images.small {
            imagesDict[.small] = small
        }
        if let thumb = images.thumb {
            imagesDict[.thumb] = thumb
        }
        if let tiny = images.tiny {
            imagesDict[.tiny] = tiny
        }
        
        let length = try container.decode(TimeInterval.self, forKey: .length)
        let name = try container.decode(String.self, forKey: .name)
        let date = try container.decode(String.self, forKey: .date)
        let siteUrl = try container.decode(URL.self, forKey: .siteUrl)
        let author = try? container.decode(String.self, forKey: .author)
        let show = try? container.decode(Show.self, forKey: .show)
        let categories = try container.decode([Category].self, forKey: .categories)
        let savedTime = try? container.decode(String.self, forKey: .savedTime)
        let youtubeId = try? container.decode(String.self, forKey: .youtubeId)
        
        self.init(deck: deck, urls: urls, guid: guid, id: id, images: imagesDict, length: length, name: name, date: date, siteUrl: siteUrl, author: author, show: show, categories: categories, savedTime: savedTime, youtubeId: youtubeId)
    }
}
