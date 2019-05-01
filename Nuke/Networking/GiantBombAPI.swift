//
//  GiantBombAPI.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-25.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

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
    
    mutating public func changeOffset(offset: Int) {
        switch self {
            case .video,
                 .category,
                 .show,
                 .currentLive,
                 .getSavedTime,
                 .saveTime,
                 .getAllSavedTimes:
            return
        case .videos(let limit, _, let sort, let categoryId, let showId):
            self = .videos(limit: limit, offset: offset, sort: sort, categoryId: categoryId, showId: showId)
        case .categories(let limit, _, let sort):
            self = .categories(limit: limit, offset: offset, sort: sort)
        case .shows(let limit, _, let sort):
            self = .shows(limit: limit, offset: offset, sort: sort)
        }
    }
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

enum Result<T> {
    case success(T)
    case failure(String)
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

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
    case badApiKey = "Api key missing or invalid."
}

struct PaginationInfo {
    var lastLimit: Int
    var lastOffset: Int
}

class GiantBombAPI {    
    private var apiKey: String?
    private var networkManager: NetworkManager
    private var paginations: [String:PaginationInfo]
    private var keychain = KeychainManager()
    
    func cancel() {
        networkManager.cancel()
    }
    
    init() {
        networkManager = NetworkManager()
        paginations = [String:PaginationInfo]()
    }
    
    private func createURLRequest(url: URL, parameters: [String:Any]) throws -> URLRequest {
        var urlRequest = URLRequest(url: url,
                                    cachePolicy: .useProtocolCachePolicy,
                                    timeoutInterval: 10.0)
        
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
    
    private func createURLRequest(fromEndpoint endpoint: Endpoint) throws -> URLRequest {
        let url = endpoint.fullURL
        var parameters = endpoint.parameters
        if apiKey == nil {
            apiKey = keychain.getApiKey()
        }
        
        guard let apiKey = apiKey else {
            throw NetworkError.badApiKey
        }
        
        parameters["api_key"] = apiKey
        
        return try createURLRequest(url: url, parameters: parameters)
    }
    
    public func authenticate(withToken code:String, completion: @escaping (Result<String>) -> Void) {
        do {
            let parameters = ["format": "json",
                              "regCode": code]
            guard let url = URL(string: "https://www.giantbomb.com/app/Nuke/get-result") else {
                completion(.failure(NetworkError.missingURL.rawValue))
                return
            }
            let urlRequest = try createURLRequest(url: url,
                                                  parameters: parameters)
            networkManager.makeRequest(urlRequest: urlRequest) { (result: Result<AuthenticationResponse>) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let response):
                    switch response.status {
                    case "success":
                        completion(.success(response.regToken))
                    default:
                        completion(.failure("Authenticatoin failed"))
                    }
                }
            }
        }
        catch {
            completion(.failure(error.localizedDescription))
        }
    }
    
    private func makeApiRequest<T:Decodable>(endpoint: Endpoint, completion: @escaping (Result<[T]>) -> Void, paginationCompletion: ((APIResponse<T>, inout [String:PaginationInfo]) -> Void)?){
        cancel()
        do {
            let urlRequest = try createURLRequest(fromEndpoint: endpoint)
            networkManager.makeRequest(urlRequest: urlRequest) { [weak self](result: Result<APIResponse<T>>) in
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
    
    private func makePaginatedApiRequest<T:Decodable>(endpoint: Endpoint, completion: @escaping (Result<[T]>) -> Void) {
        let paginationCompletion: ((APIResponse<T>, inout [String:PaginationInfo]) -> Void) = { [endpoint] (apiResponse, paginations: inout[String:PaginationInfo]) in
            paginations[endpoint.path] = PaginationInfo(lastLimit: apiResponse.limit, lastOffset: apiResponse.offset)
        }
        
        guard let paginationInfo = paginations[endpoint.path] else {
            makeApiRequest(endpoint: endpoint, completion: completion, paginationCompletion: paginationCompletion)
            return
        }
        
        let newOffset = paginationInfo.lastLimit + paginationInfo.lastOffset
        var endpointCopy = endpoint
        endpointCopy.changeOffset(offset: newOffset)
        makeApiRequest(endpoint: endpointCopy, completion: completion, paginationCompletion: paginationCompletion)
        
    }
}

// Shows Endpoint
extension GiantBombAPI {
    
    public func getShows(limit: Int?,
                         offset: Int?,
                         sort: SortOptions?,
                         completion: @escaping (Result<[Show]>) -> Void) {
        let endpoint = Endpoint.shows(limit: limit, offset: offset, sort: sort)
        makeApiRequest(endpoint: endpoint, completion: completion, paginationCompletion: nil)
    }
    
    public func getNextPageShows(limit: Int?,
                                 sort: SortOptions?,
                                 completion: @escaping (Result<[Show]>) -> Void) {
        let endpoint = Endpoint.shows(limit: limit, offset: nil, sort: sort)
        makePaginatedApiRequest(endpoint: endpoint, completion: completion)
    }
}

// Categories Endpoint
extension GiantBombAPI {
    public func getCategories(limit: Int?,
                         offset: Int?,
                         sort: SortOptions?,
                         completion: @escaping (Result<[Category]>) -> Void) {
        let endpoint = Endpoint.categories(limit: limit, offset: offset, sort: sort)
        makeApiRequest(endpoint: endpoint, completion: completion, paginationCompletion: nil)
    }
    
    public func getNextPageCategories(limit: Int?,
                                 sort: SortOptions?,
                                 completion: @escaping (Result<[Category]>) -> Void) {
        let endpoint = Endpoint.categories(limit: limit, offset: nil, sort: sort)
        makePaginatedApiRequest(endpoint: endpoint, completion: completion)
    }
}
