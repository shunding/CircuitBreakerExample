//
//  ResourceProvider.swift
//  CircuitBreaker
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import Foundation

/// Resource retrieving error. Has only several cases for simplicity.
///
/// - badResponse: if response is broken.
/// - noData: if some malformed data received.
/// - badStatus: non-200 status code received.
/// - serviceUnavailable: if service is unavailable.
/// - other: any other error with error itself as associated value.
enum ResourceProviderError: Error {
    case badResponse
    case noData
    case badStatus(status: Int)
    case serviceUnavailable
    case other(error: Error)
}

/// Wrapper object for resorce response. Has only ```data``` 
/// and ```statusCode``` fields for simplicity.
struct ResourceResponse {
    let data: Data
    let statusCode: Int
}

extension ResourceResponse: CustomStringConvertible {
    var description: String {
        return "\(statusCode)"
    }
}

/// Wraps result of call to the resource.
///
/// - success: in case of success wraps the parametrized value.
/// - failure: in case of failure wraps ```ResourceProviderError```.
enum ResourceProviderResult<Value> {
    case success(Value)
    case failure(ResourceProviderError)
}

extension ResourceProviderResult: CustomStringConvertible {
    var description: String {
        switch self {
        case .success(let value):
            return "Success: \(value)"
        case .failure(let error):
            return "Error: \(error)"
        }
    }
}

/// Shorthand for resource result completion closure.
typealias ResourceResultCompletion = (ResourceProviderResult<ResourceResponse>) -> Void

/// Shold be adopted by objects which need to have universal interface
/// to make requests for ```ResourceType```s.
protocol ResourceProviderType {
    /// Constrained to ```ResourceType```.
    associatedtype T: ResourceType
    
    
    /// Interface method for making requests to ```ResourceType``` objects.
    /// Non-cancellable for simplicity.
    ///
    /// - Parameters:
    ///   - resource: concrete resource implementation.
    ///   - completion: resulting completion closure.
    func request(resource: T, with completion: @escaping ResourceResultCompletion)
}
