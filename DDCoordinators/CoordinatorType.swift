//
//  WeakArray.swift
//  DDCoordinators
//
//  Created by Dan Dunnington on 01/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 A non generic coordinator base type for coordiantors.
 
 All coordinators should conform to this protocol as all coordinators should conform to the `Coordinator` base class
 */
public protocol CoordinatorType: class {
    
    func start(animated: Bool, completion: (()->Void)?)
    
    var children: [WeakCoordinatorType] { get set }
    
    var parent: CoordinatorType? { get set }
    
    var rootViewController: UIViewController? { get }
    
    var _strongNavigationController: UINavigationController? { get }
}

extension CoordinatorType {
    var navigationController: UINavigationController? {
        return rootViewController?.navigationController
    }
}

public class WeakCoordinatorType {
    
    weak var value: CoordinatorType?
    
    init(value: CoordinatorType) {
        self.value = value
    }
}

public extension CoordinatorType {
    
    @discardableResult
    func startChild<C: CoordinatorType>(animated: Bool, _ child: C) -> C {
        children.append(child)
        child.parent = self
        child.start(animated: animated, completion: nil)
        return child
    }
    
}

extension Array where Element == WeakCoordinatorType {
    
    @discardableResult
    internal mutating func prune() -> [CoordinatorType] {
        self.removeAll { $0.value == nil }
        return coordinators()
    }
    
    internal func coordinators() -> [CoordinatorType] {
        return compactMap { $0.value }
    }
    
    internal mutating func append(_ coordinator: CoordinatorType) {
        self.append(WeakCoordinatorType(value: coordinator))
    }
}
