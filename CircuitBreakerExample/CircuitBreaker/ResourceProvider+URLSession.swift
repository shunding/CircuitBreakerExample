//
//  ResourceProvider+URLSession.swift
//  CircuitBreaker
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import UIKit

// MARK: - Default implemetation

// Simplified default implementation which uses ```URLSession```'s ```dataTask```.
// Just for this sample purposes.
extension ResourceProviderType {
    func request(resource: T, with completion: @escaping ResourceResultCompletion) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = URLSession.shared.dataTask(with: resource.request) { (data, response, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            // In closure we need to handle results properly
            // We need to notify our observers about several events:
            if let error = error {
                print("Data Task Error: \(error)")
                
                // In case of error
                completion(.failure(.other(error: error)))
            } else {
                
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(.badResponse))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                if 200 ..< 300 ~= response.statusCode {
                    // In case of success -- pass data to observers
                    completion(.success(ResourceResponse(data: data, statusCode: response.statusCode)))
                } else {
                    // In case of bad request status -- notify about error as well
                    completion(.failure(.badStatus(status: response.statusCode)))
                }
            }
        }
        task.resume()
    }
}
