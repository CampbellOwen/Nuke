//
//  Category.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

struct Category: Codable, CustomStringConvertible, VideoCollectionInfo
{
    var id: Int
    var name: String
    var siteUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case siteUrl = "site_detail_url"
    }
    
    var description: String {
        return name
    }
}
