//
//  ResourceType.swift
//  CircuitBreaker
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import Foundation

/// Represents HTTP methods such as GET, POST, PUT, DELETE, etc.
///
/// - get: Currently, only GET method used for all API calls used in the app.
enum Method: String {
    case get = "GET"
}

/// By implementing this protocol we can provide a set of data required
/// to create a URL request.
protocol ResourceType {
    
    /// Implement this computed property to specify which
    /// base URL will be used to construct request.
    var baseUrl: String { get }
    
    /// Implement this computed property to specifing which
    /// HTTP mehtod should be used by ```URLRequest```.
    var method: Method { get }
    
    /// Implement this to specify a path to the endpoint.
    /// This should be a path relative to the ```baseURL```.
    var path: String { get }
    
    /// Here should be a set of data to generate a
    /// query string or body for ```URLRequest```.
    var parameters: [String: String]? { get }
    
    /// Provids custom HTTP header fields.
    var headers: [String: String]? { get }
}

// MARK: - Defaults
extension ResourceType {
    var method: Method { return .get }
    var parameters: [String: String]? { return nil }
    var headers: [String: String]? { return nil }
}
