//
//  GiantBombService.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//
import Moya
import Foundation

struct SortOptions {
    var direction: Direction
    var field: String
}

enum Direction: String {
    case ascending = "asc"
    case descending = "desc"
}

enum GiantBombService {
    case video(guid: Int)
    case videos(limit: Int?, offset: Int?, sort: SortOptions?, categoryId: String?, showId: String?)
    case category(id: String)
    case categories(limit: Int?, offset: Int?, sort: SortOptions?)
    case show(guid: String)
    case shows(limit: Int?, offset: Int?, sort: SortOptions?)
    case currentLive
    case getSavedTime(id: String)
    case saveTime(id: String, time: TimeInterval)
    case getAllSavedTimes
}

extension GiantBombService: TargetType
{
    var baseURL: URL { return URL(string: "https://www.giantbomb.com/api")! }
    
    var path: String {
        switch self {
        case .video(let guid):
            return "/video/\(guid)"
        case .videos:
            return "/videos"
        case .category(let id):
            return "/video_category/\(id)"
        case .categories:
            return "/video_categories"
        case .show(let guid):
            return "/video_show/\(guid)"
        case .shows:
            return "/video_shows"
        case .currentLive:
            return "/video/current-live"
        case .getSavedTime:
            return "/video/get-saved-time"
        case .saveTime:
            return "/video/save-time"
        case .getAllSavedTimes:
            return "/video/get-all-saved-times"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        switch self {
        case .video:
            return stubbedResponse("video")
        case .videos:
            return stubbedResponse("videos")
        case .category:
            return stubbedResponse("category")
        case .categories:
            return stubbedResponse("categories")
        case .show:
            return stubbedResponse("show")
        case .shows:
            return stubbedResponse("shows")
        case .currentLive:
            return stubbedResponse("currentLive")
        case .getSavedTime:
            return stubbedResponse("getSavedTime")
        case .saveTime:
            return stubbedResponse("saveTime")
        case .getAllSavedTimes:
            return stubbedResponse("getAllSavedTimes")
        }
    }
    
    var task: Task {
        var params = [String:Any]()
        switch self {
        case .video, .category, .show, .currentLive, .getAllSavedTimes: break
        case .categories(let limit, let offset, let sort), .shows(let limit, let offset, let sort):
            params["limit"] = limit
            params["offset"] = offset
            if let sortField = sort?.field, let sortDirection = sort?.direction.rawValue {
                params["sort"] = "\(sortField):\(sortDirection)"
            }
        case .videos(let limit, let offset, let sort, let categoryId, let showId):
            params["limit"] = limit
            params["offset"] = offset
            if let sortField = sort?.field, let sortDirection = sort?.direction.rawValue {
                params["sort"] = "\(sortField):\(sortDirection)"
            }
            if categoryId != nil || showId != nil {
                var paramString = ""
                if categoryId != nil {
                    paramString += "video_category:\(categoryId!),"
                }
                if showId != nil {
                    paramString += "video_show:\(showId!)"
                }
                params["filter"] = paramString
            }
        case .getSavedTime(let id):
            params["video_id"] = id
        case .saveTime(let id, let time):
            params["video_id"] = id
            params["time-to-save"] = time
        }
        params["api_key"] = "3f76ef5f20263c6f4ae1381e60ef902e22af58ff"
        params["format"] = "json"
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return [:]
    }
    
}

func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}
