//
//  WeakArray.swift
//  LittleJohn
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
public protocol CoordinatorType: AnyObject {
    
    func start(animated: Bool, completion: (()->Void)?)
        
    var parent: CoordinatorType? { get set }
    
    var rootViewController: UIViewControllerType? { get }
    
    var _strongNavigationController: UINavigationControllerType? { get }
    
    func deallocateStrongNavController()
}

extension CoordinatorType {
    var navigationController: UINavigationControllerType? {
        return rootViewController?.navigationControllerType
    }
}

public extension CoordinatorType {
    
    @discardableResult
    func startChild<C: CoordinatorType>(animated: Bool, _ child: C) -> C {
        child.parent = self
        child.start(animated: animated, completion: nil)
        return child
    }
    
    func startChildType(animated: Bool, _ child: CoordinatorType) {
        child.parent = self
        child.start(animated: animated, completion: nil)
    }
    
}
