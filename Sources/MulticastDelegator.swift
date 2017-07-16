//
//  KVMulticastDelegator.swift
//  KVDownloadManager
//
//  Created by Keshav on 6/29/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import Foundation

open class MulticastDelegator<T>: NSObject
{
    private final class WeakWrapper:Equatable {
        weak var value: AnyObject?
        init(value: AnyObject) {
            self.value = value
        }
        
        static func ==(lhs: WeakWrapper, rhs: WeakWrapper) -> Bool {
            return lhs.value === rhs.value
        }
    }
    
    private var delegates: [WeakWrapper] = []
    
    open func addDelegate(_ delegate: T) {
        let weak = WeakWrapper(value: delegate as AnyObject)
        if !delegates.contains(weak) {
            delegates.append(weak)
        }
    }
    
    public init(weak:Bool = true) {
    
    }
    
    open func removeDelegate(_ delegate: T) {
        let weak = WeakWrapper(value: delegate as AnyObject)
        if let index = delegates.index(of: weak) {
            delegates.remove(at: index)
        }
        
        // guard let index = delegates.index(where: { $0.value == delegate }) else { return nil }
    }
    
    open func invoke(_ invocation: @escaping (T) -> ()) {
        delegates = delegates.filter { $0.value != nil }
        
        delegates.forEach {
            if let delegate = $0.value as? T {
                invocation(delegate)
            }
        }
        
    }
    
    public static func += (lhs: MulticastDelegator<T>, rhs: T) {
        lhs.addDelegate(rhs)
    }
    
    public static func -= (lhs: MulticastDelegator<T>, rhs: T) {
        lhs.removeDelegate(rhs)
    }
    
}
