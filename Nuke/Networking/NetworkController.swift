//
//  NetworkController.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-04-30.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import Foundation

enum ResultNew<T> {
    case success(T)
    case failure(NetworkErrorNew)
}

enum NetworkErrorNew: String {
    case authenticationError = "You need to be authenticated."
    case badRequest = "Bad request."
    case failed = "Network request failed."
    case unableToDecode = "Could not decode response."
}


class NetworkController {
    
    var apiKey: String
    private var session: URLSession
    private var sessionConfig: URLSessionConfiguration
    
    private let auth_endpoint = URL(string: "https://www.giantbomb.com/app/Nuke/get-result")!
    
    init(apiKey: String, sessionConfig: URLSessionConfiguration) {
        self.apiKey = apiKey
        self.sessionConfig = sessionConfig
        self.session = URLSession(configuration: sessionConfig)
    }
    
    fileprivate func createURL(url: URL, parameters: [String:String]) -> URL {
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        urlComponents.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: String(value))
            urlComponents.queryItems?.append(queryItem)
        }
        
        return urlComponents.url!
    }
    
    func authenticate(with token: String, completion: @escaping (ResultNew<String>) -> Void) -> URLSessionDataTask {
        var params = [String:String]()
        params["regCode"] = token
        params["format"] = "json"
        
        let url = createURL(url: auth_endpoint, parameters: params)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.failed))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.badRequest))
                return
            }
            guard let data = data else {
                completion(.failure(.unableToDecode))
                return
            }
            var authResponse: AuthenticationResponse?
            do {
                let jsonDecoder = JSONDecoder()
                authResponse = try jsonDecoder.decode(AuthenticationResponse.self, from: data)
            }
            catch {
                completion(.failure(.unableToDecode))
                return
            }
            guard let auth = authResponse else {
                completion(.failure(.unableToDecode))
                return
            }
            guard auth.status == "success" else {
                completion(.failure(.authenticationError))
                return
            }
            
            completion(.success(auth.regToken))
            
        }
        task.resume()
        return task
    }
    
    func load<T: ApiResource>(with resource: T, completion: @escaping (ResultNew<APIResponse<T.Model>>) -> Void) -> URLSessionDataTask {
        
        var params = resource.params
        params["api_key"] = String(apiKey)
        params["format"] = "json"
        
        let url = createURL(url: resource.url, parameters: params)
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(.failure(.failed))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.failed))
                return
            }
            
            if httpResponse.statusCode == 404 {
                completion(.failure(.badRequest))
                return
            }
            
            if httpResponse.statusCode == 401 {
                completion(.failure(.authenticationError))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.failed))
                return
            }
            
            var decoded: APIResponse<T.Model>?
            
            if let data = data{
                do {
                    let jsonDecoder = JSONDecoder()
                    decoded = try jsonDecoder.decode(APIResponse<T.Model>.self, from: data)
                }
                catch{
                    completion(.failure(.unableToDecode))
                    return
                }
               
            } else {
                completion(.failure(.badRequest))
                return
            }
            
            if let decoded = decoded {
                 completion(.success(decoded))
            }
            else {
                completion(.failure(.failed))
            }
            
        }
        
        task.resume()
        return task
    }
    
    
    func cancel() {
        session.invalidateAndCancel()
        session = URLSession(configuration: sessionConfig)
    }
}
