//
//  CircuitBreakerProvider.swift
//  CircuitBreakerSample
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import Foundation

/// Customized implementation of ```ResourceProviderType``` protocol.
/// Extends ```BaseResourceProvider``` class.
/// Uses instance of ```CircuitBreaker``` object to manage requests.
class CircuitBreakerProvider<U: ResourceType>: BaseResourceProvider<U> {
    private var breaker: CircuitBreaker
    
    /// Constructs new ```CircuitBreakerProvider``` object.
    ///
    /// - Parameter breaker: customizable ```CircuitBreaker``` object. Uses
    ///                      standard one by default.
    init(breaker: CircuitBreaker = CircuitBreaker()) {
        self.breaker = breaker
    }
    
    func request(resource: U, with completion: @escaping ResourceResultCompletion) {
        let command: CircuitBreaker.Operation.Command = { breaker in
            super.request(resource: resource) { result in
                switch result {
                case .success(let value):
                    breaker.success()
                    completion(.success(value))
                case .failure(let error):
                    breaker.failure(error: error)
                }
            }
        }
        
        let fallback: CircuitBreaker.Operation.Fallback = { (_, _) in
            completion(.failure(.serviceUnavailable))
        }
        
        let operation = CircuitBreaker.Operation(command: command, fallback: fallback)
        
        breaker.schedule(operation: operation)
    }
}
