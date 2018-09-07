//
//  ShowService.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-23.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation
import Moya

class ShowService {
    private var provider: MoyaProvider<GiantBombService>
    private var fetchInProgress = false

    init(with provider:MoyaProvider<GiantBombService>) {
        self.provider = provider
    }
    
    public func getShows(limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (Result<[Show]>) -> Void) {
        fetchInProgress = true
        provider.request(.shows(limit: limit, offset: offset, sort: sort)) { (result) in
            self.fetchInProgress = false
            
            switch result {
            case .success(let moyaResponse):
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    let data = try! moyaResponse.mapString()
                    let decoder = JSONDecoder()
                    
                    let resultsMeta = try decoder.decode(ApiResponse<Show>.self, from: data.data(using: .utf8)!)
                    completion(.success(resultsMeta.results))
                }
                catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
