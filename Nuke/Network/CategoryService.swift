//
//  Category.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-23.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation
import Moya

class CategoryService {
    private var provider: MoyaProvider<GiantBombService>
    
    init(with provider:MoyaProvider<GiantBombService>) {
        self.provider = provider
    }
    
    public func getCategories(limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (ApiResponse<Category>) -> Void) {
        provider.request(.categories(limit: limit, offset: offset, sort: sort)) { (result) in
            switch result {
            case .failure(let error):
                print("Error:\(error)")
            case .success(let response):
                do {
                    try _ = response.filterSuccessfulStatusCodes()
                    let data = try! response.mapString()
                    let decoder = JSONDecoder()
                    
                    let resultsMeta = try decoder.decode(ApiResponse<Category>.self, from: data.data(using: .utf8)!)
                    completion(resultsMeta)
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}
