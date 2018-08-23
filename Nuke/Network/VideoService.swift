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
    
    init(with provider:MoyaProvider<GiantBombService>) {
        self.provider = provider
    }
    
    private func getVideos(showId:String?, categoryId:String?, limit:Int?, offset:Int?, sort:SortOptions?, completion: @escaping (ApiResponse<Video>) -> Void) {
        provider.request(.videos(limit: limit, offset: offset, sort: nil, categoryId: categoryId, showId:showId)) { (result) in
            switch result {
            case .success(let moyaResponse):
                do {
                    try _ = moyaResponse.filterSuccessfulStatusCodes()
                    let data = try! moyaResponse.mapString()
                    let decoder = JSONDecoder()
                    
                    let resultsMeta = try decoder.decode(ApiResponse<Video>.self, from: data.data(using: .utf8)!)
                    completion(resultsMeta)
                }
                catch {
                    print("Error: \(error)")
                }
                
            case .failure(let error):
                print("Error:\(error)")
            }
        }
    }
    
    public func getVideos(fromCategory categoryId: String, limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (ApiResponse<Video>) -> Void) {
        getVideos(showId: nil, categoryId: categoryId, limit: limit, offset: offset, sort: sort, completion: completion)
    }
    
    public func getVideos(fromShow showId: String, limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (ApiResponse<Video>) -> Void) {
        getVideos(showId: showId, categoryId: nil, limit: limit, offset: offset, sort: sort, completion: completion)
    }
    
    public func getVideos(limit:Int? = nil, offset:Int? = nil, sort:SortOptions?=nil, completion: @escaping (ApiResponse<Video>) -> Void) {
        getVideos(showId: nil, categoryId: nil, limit: limit, offset: offset, sort: sort, completion: completion)
    }

}
