//
//  BaseResourceProvider.swift
//  CircuitBreakerExample
//
//  Created by Alex Drozhak on 9/14/17.
//  Copyright © 2017 93Hz. All rights reserved.
//

import Foundation

/// Base implemention of ```ResourceProviderType```. Uses default
/// implementation for ```request(_::)``` method from the protocol's
/// extension. Constrained to ```ResourceType``` objects.
class BaseResourceProvider<U: ResourceType>: ResourceProviderType {
    typealias T = U
}
