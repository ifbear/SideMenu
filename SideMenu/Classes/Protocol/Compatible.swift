//
//  Compatible.swift
//  
//
//  Created by iferret on 2023/1/18.
//

import Foundation


/// CompatibleWrapper
struct CompatibleWrapper<Base> {
    public let base: Base
    public init(base: Base) {
        self.base = base
    }
}

/// Compatible
protocol Compatible: AnyObject {}
extension Compatible {
    /// CompatibleWrapper<Self>
    public var side: CompatibleWrapper<Self> {
        get { .init(base: self) }
        set { }
    }
}

/// CompatibleValue
protocol CompatibleValue {}
extension CompatibleValue {
    /// CompatibleWrapper<Self>
    public var side: CompatibleWrapper<Self> {
        get { .init(base: self) }
        set { }
    }
}
