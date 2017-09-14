//
//  ResourceType+URLRequest.swift
//  CircuitBreaker
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import Foundation

extension ResourceType {
    
    /// Generates ```URLRequest``` based on current ```ResourceType``` setup.
    ///
    /// - Returns: generated ```URLRequest```
    var request: URLRequest {
        guard let baseUrl = URL(string: baseUrl) else {
            fatalError("Can not construct URL from: \(self.baseUrl)")
        }
        let url = baseUrl.appendingPathComponent(path)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components from \(url)")
        }
        
        if let parameters = parameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: String($0), value: String($1))
            }
        }
        
        guard let finalUrl = components.url else {
            fatalError("Unable to retrieve final URL")
        }
        
        var request = URLRequest(url: finalUrl)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            headers.forEach { (key, value) in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
