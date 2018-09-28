//
//  GiantBombAPI.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-25.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}

struct SortOptions {
    var direction: Direction
    var field: String
}

enum Direction: String {
    case ascending = "asc"
    case descending = "desc"
}

enum Endpoint {
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

extension Endpoint {
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
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var fullURL: URL {
        return baseURL.appendingPathComponent(path)
    }
    
    var parameters: [String:Any] {
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
        params["format"] = "json"
        return params
    }
}

enum NetworkResponse: String {
    case success
    case authenticationError = "You need to be authenticated."
    case badRequest = "Bad request."
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "Could not decode response."
}

enum Result<T> {
    case success(T)
    case failure(String)
}

struct PaginationInfo {
    var lastLimit: Int
    var lastOffset: Int
}

class GiantBombAPI {    
    private var apiKey: String
    private var networkManager: NetworkManager
    private var paginations: [String:PaginationInfo]
    
    func cancel() {
        networkManager.cancel()
    }
    
    init(apiKey: String) {
        self.apiKey = "3f76ef5f20263c6f4ae1381e60ef902e22af58ff"
        networkManager = NetworkManager()
        paginations = [String:PaginationInfo]()
    }
    
    private func createURLRequest(endpoint: Endpoint) throws -> URLRequest {
        var urlRequest = URLRequest(url: endpoint.fullURL,
                                    cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
        guard let url = urlRequest.url else { throw NetworkError.missingURL }
        var parameters = endpoint.parameters
        parameters["api_key"] = apiKey
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            !parameters.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        return urlRequest
    }
    
    private func makeRequest<T:Decodable>(endpoint: Endpoint, completion: @escaping (Result<[T]>) -> Void, paginationCompletion: ((GiantBombApiResponse<T>, inout [String:PaginationInfo]) -> Void)?){
        do {
            let urlRequest = try createURLRequest(endpoint: endpoint)
            networkManager.makeRequest(urlRequest: urlRequest) { [weak self](result: Result<GiantBombApiResponse<T>>) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    if self?.paginations != nil {
                        paginationCompletion?(data, &self!.paginations)
                    }
                    completion(.success(data.results))
                }
            }
        }
        catch {
            completion(.failure(error.localizedDescription))
        }
    }
}

// Shows Endpoint
extension GiantBombAPI {
    
    public func getShows(limit: Int?,
                         offset: Int?,
                         sort: SortOptions?,
                         completion: @escaping (Result<[Show]>) -> Void) {
        let endpoint = Endpoint.shows(limit: limit, offset: offset, sort: sort)
        makeRequest(endpoint: endpoint, completion: completion, paginationCompletion: nil)
    }
    
    public func getNextPageShows(limit: Int?,
                                 sort: SortOptions?,
                                 completion: @escaping (Result<[Show]>) -> Void) {
        guard let paginationInfo = paginations[Endpoint.shows(limit: nil, offset: nil, sort: nil).path] else {
            getShows(limit: limit, offset: nil, sort: sort, completion: completion)
            return
        }
        let newOffset = paginationInfo.lastLimit + paginationInfo.lastOffset
        let endpoint = Endpoint.shows(limit: limit, offset: newOffset, sort: sort)
        makeRequest(endpoint: endpoint, completion: completion) {[endpoint] (apiResponse, paginations: inout[String:PaginationInfo]) in
            paginations[endpoint.path] = PaginationInfo(lastLimit: apiResponse.limit, lastOffset: apiResponse.offset)
        }
    }
}

// Categories Endpoint
extension GiantBombAPI {
    public func getCategories(limit: Int?,
                              offset: Int?,
                              sort: SortOptions?,
                              completion: @escaping (Result<[Category]>) -> Void) {
        let endpoint = Endpoint.categories(limit: limit, offset: offset, sort: sort)
//        makeRequest(endpoint: endpoint, completion: completion)
    }
}
