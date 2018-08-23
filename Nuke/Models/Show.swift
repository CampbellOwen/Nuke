//
//  Show.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

struct Show: Decodable, CustomStringConvertible, VideoCollectionInfo
{
    var id: Int
    var name: String
    var siteUrl: URL
    var images: [ImageQuality: URL]
    
    enum CodingKeys: String, CodingKey {
        case id
        case images = "image"
        case name = "title"
        case siteUrl = "site_detail_url"
    }
    
    var description: String {
        return name
    }
}

extension Show {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        
        let images = try container.decode(Images.self, forKey: .images)
        var imagesDict = [ImageQuality:URL]()
        imagesDict[.icon] = images.icon
        imagesDict[.medium] = images.medium
        imagesDict[.screen] = images.screen
        imagesDict[.screenLarge] = images.screenLarge
        imagesDict[.large] = images.large
        imagesDict[.original] = images.original
        imagesDict[.small] = images.small
        imagesDict[.thumb] = images.thumb
        imagesDict[.tiny] = images.tiny
        
        let name = try container.decode(String.self, forKey: .name)
        let siteUrl = try container.decode(URL.self, forKey: .siteUrl)
        
        self.init(id: id, name: name, siteUrl: siteUrl, images: imagesDict)
    }
}
