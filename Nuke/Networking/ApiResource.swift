//
//  ApiResource.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-04-30.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import Foundation

enum Direction: String {
    case ascending = "asc"
    case descending = "desc"
}

struct SortOptions {
    var direction: Direction
    var field: String
}

protocol ApiResource {
    associatedtype Model: Decodable
    var methodPath: String {get}
    var offset: Int {get set}
    var limit: Int {get set}
    var sort: SortOptions? {get set}
    var filter: [String:String]? {get set}
}

extension ApiResource {
    var url: URL {
        let baseURL = URL(string: "https://www.giantbomb.com/api")!
        return baseURL.appendingPathComponent(methodPath)
    }
    
    var params: [String:String] {
        var params = [String:String]()
        if let sortField = sort?.field, let sortDirection = sort?.direction.rawValue {
            params["sort"] = "\(sortField):\(sortDirection)"
        }
        if let filter = filter {
            let filterStrings = filter.map { (key, value) in
                return "\(key):\(value)"
            }
            let joined = filterStrings.joined(separator: ",")
            params["filter"] = joined
        }
        params["offset"] = String(offset)
        params["limit"] = String(limit)
        
        
        return params
    }
}
