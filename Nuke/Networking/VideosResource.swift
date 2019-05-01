//
//  VideosResource.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-05-01.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import Foundation

class VideosResource : ApiResource {
    typealias Model = Video
    
    private let show_filter = "video_show"

    let methodPath: String = "videos"
    
    var offset: Int = 0
    
    var limit: Int = 0
    
    var sort: SortOptions?
    
    var filter: [String:String]?
    
    func filter(show id: Int) {
        if filter == nil {
            filter = [String:String]()
        }
        filter?[show_filter] = String(id)
    }
    
}
