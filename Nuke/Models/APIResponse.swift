//
//  Meta.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

struct APIResponse<ResultType:Decodable>: Decodable, CustomStringConvertible
{
    var error: String
    var limit: Int
    var offset: Int
    var numberReturnedResults: Int
    var numberTotalResults: Int
    var statusCode: Int
    var results: [ResultType]
    
    enum CodingKeys: String, CodingKey {
        case error
        case limit
        case offset
        case numberReturnedResults = "number_of_page_results"
        case numberTotalResults = "number_of_total_results"
        case statusCode = "status_code"
        case results = "results"
    }
    
    var description: String {
        return "\(numberReturnedResults)/\(numberTotalResults) results:\n\(results)"
    }
}
