//
//  ShowsResource.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-04-30.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import Foundation

class ShowsResource : ApiResource {
    typealias Model = Show

    var limit: Int = 100
    
    var sort: SortOptions?
    
    var filter: [String : String]?
        
    let methodPath: String = "video_shows"
    
    var offset: Int = 0
    
}
