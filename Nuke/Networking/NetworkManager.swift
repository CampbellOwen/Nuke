//
//  NetworkManager.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-26.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

class NetworkManager {
    
    private var task: URLSessionTask?
    
    public func makeRequest<T:Decodable>(urlRequest: URLRequest, completion: @escaping (Result<T>) -> Void){
        let desc = urlRequest.description
        let url = urlRequest.url
        task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                completion(.failure(NetworkResponse.failed.rawValue))
            }
            
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodedItem = try jsonDecoder.decode(T.self, from: data)
                    completion(.success(decodedItem))
                }
                catch {
                    completion(.failure(error.localizedDescription))
                }
            }
            else {
                print(response?.debugDescription ?? "failed")
                completion(.failure(NetworkResponse.noData.rawValue))
            }
            
        }
        task?.resume()
    }
    
    public func cancel() {
        task?.cancel()
    }
}
