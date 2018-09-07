//
//  VideoService.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation
import Moya

class VideoService
{
    private var provider: MoyaProvider<GiantBombService>
    
    private var fetchInProgress = false
    
    private var lastOffset: Int?
    private var lastLimit: Int?
    private var lastShowId: String?
    private var lastCategoryId: String?
    private var lastSort: SortOptions?
    
    init(with provider:MoyaProvider<GiantBombService>) {
        self.provider = provider
    }
    
    private func fetch(showId:String?, categoryId:String?, limit:Int?, offset:Int?, sort:SortOptions?, completion: @escaping (Result<[Video]>) -> Void) {
        guard !fetchInProgress else {
            return
        }
        fetchInProgress = true
        provider.request(.videos(limit: limit, offset: offset, sort: nil, categoryId: categoryId, showId:showId)) { (result) in
            
            self.fetchInProgress = false
            
            switch result {
            case .success(let moyaResponse):
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    let data = try! moyaResponse.mapString()
                    let decoder = JSONDecoder()
                    do {
                        let resultsMeta = try decoder.decode(ApiResponse<Video>.self, from: data.data(using: .utf8)!)
                        
                        self.lastOffset = resultsMeta.offset
                        self.lastLimit = resultsMeta.limit
                        self.lastSort = sort
                        self.lastShowId = showId
                        self.lastCategoryId = categoryId
                        
                        completion(.success(resultsMeta.results))
                    }
                    catch {
                        completion(.failure(error))

                    }
                    
                }
                catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func getVideos(fromCategory categoryId: String, limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (Result<[Video]>) -> Void) {
        fetch(showId: nil, categoryId: categoryId, limit: limit, offset: offset, sort: sort, completion: completion)
    }
    
    public func getVideos(fromShow showId: String, limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (Result<[Video]>) -> Void) {
        fetch(showId: showId, categoryId: nil, limit: limit, offset: offset, sort: sort, completion: completion)
    }
    
    public func getVideos(limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (Result<[Video]>) -> Void) {
        fetch(showId: nil, categoryId: nil, limit: limit, offset: offset, sort: sort, completion: completion)
    }
    
    public func getNextPage(completion: @escaping (Result<[Video]>) -> Void) {
        let offset = (lastOffset ?? 0) + (lastLimit ?? 0)
        fetch(showId: lastShowId, categoryId: lastCategoryId, limit: lastLimit, offset: offset, sort: lastSort, completion: completion)
    }

}
