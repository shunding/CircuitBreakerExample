//
//  CircuitBreaker.swift
//  CircuitBreaker
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import Foundation
import Dispatch

/// This class implements Circuit Breaker design pattern.
/// Has three states: Closed, Open, Half Open.
/// If managed request returns error - makes n retries (```retries``` property).
/// If all n retries are failed - goes to Open state for ```resetDelay``` seconds.
/// After ```resetDelay``` is reached - switches to Half Open state.
/// In HalfOpen state passes one request and switches to Closed/Open in case of
/// success/failure.
public class CircuitBreaker {
    
    /// Circuit Breaker Operation payload.
    /// Wraps the operation managed by Circuit Breaker.
    public struct Operation {
        public typealias Command = (CircuitBreaker) -> Void
        public typealias Fallback = (CircuitBreaker, Error?) -> Void
        
        /// Main operation closure. Holds the client operation which should
        /// be managed by Circuit Breaker.
        let command: Command
        
        /// Fallback closure. Used to notify client about `trip` cases.
        let fallback: Fallback
    }
    
    /// Circuit Breaker state
    ///
    /// - closed: allows all requests, returns all responses.
    /// - open: all requests disabled, returns failure.
    /// - halfOpen: allows one request, switches back to 
    /// ```closed```/```open``` in case of success/failure response.
    public enum State {
        case closed
        case open
        case halfOpen
    }
    
    /// Number of retries when state is ```closed``` but request failed.
    public let retries: Int
    
    /// Number of seconds Circuit Breaker will wait after last failure
    /// before switch to ```halfOpen``` state.
    public let resetTimeout: TimeInterval
    
    /// Number of seconds between retries.
    public let retryDelay: TimeInterval
    
    private var failureCount = 0
    
    private var operations = [Operation]() {
        didSet {
            runNext()
        }
    }
    
    private var currentOperation: Operation?

    /// Returns the current state of Circuit Breaker.
    public var state: State {

        if let lastFailureTime = lastFailureTime,
            (failureCount >= retries) && (Date().timeIntervalSince1970 - lastFailureTime > resetTimeout) {
            return .halfOpen
        }
        
        if failureCount >= retries {
            return .open
        }

        return .closed
    }
    
    private var lastError: Error?
    private var lastFailureTime: TimeInterval?
    
    /// Constructs new Circuit Breaker object.
    ///
    /// - Parameters:
    ///   - resetTimeout: Number of seconds Circuit Breaker will wait after last
    ///                   failure before switch to ```halfOpen``` state (default: 10).
    ///   - retries: Number of retries when state is ```closed``` but request 
    ///              failed (default: 3).
    ///   - retryDelay: Number of seconds between retries (default: 1).
    public init(resetTimeout: TimeInterval = 10,
                retries: Int = 3,
                retryDelay: TimeInterval = 1) {
        self.resetTimeout = resetTimeout
        self.retries = retries
        self.retryDelay = retryDelay
    }
    
    /// Used to schedule new client call. Adds passed operation into the queue.
    ///
    /// - Parameter operation: operation instance configured by client.
    public func schedule(operation: Operation) {
        operations.append(operation)
    }
    
    private func runNext() {
        guard operations.count > 0, currentOperation == nil else { return }
        currentOperation = operations.remove(at: 0)
        switch state {
        case .closed, .halfOpen:
            execute()
        case .open:
            trip()
        }
    }
    
    /// Used to notify Circuit Breaker by the client when 
    /// operation is succeeded.
    public func success() {
        reset()
        runNext()
    }
    
    /// Used to notify Circuit Breaker by the client when
    /// operation is failed.
    ///
    /// - Parameter error: passed by client to store last error.
    public func failure(error: Error) {
        lastError = error
        lastFailureTime = Date().timeIntervalSince1970
        failureCount += 1
        
        switch state {
        case .closed:
            retry(after: retryDelay)
        case .open, .halfOpen:
            trip()
        }
    }
    
    private func reset() {
        failureCount = 0
        lastFailureTime = nil
        lastError = nil
        currentOperation = nil
    }
    
    private func execute() {
        currentOperation?.command(self)
    }
    
    private func retry(after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.execute()
        }
    }
    
    private func trip() {
        currentOperation?.fallback(self, lastError)
        currentOperation = nil
        runNext()
    }
}
