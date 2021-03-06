//
//  UINavigationControllerType.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 15/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
 Protocol implementation of the `UINaviationController` interface used in the framework
 
 This protocol works with the `UIViewControllerType` interface
 */
public protocol UINavigationControllerType: UIViewControllerType {
    
    func pushViewControllerType(_ viewController: UIViewControllerType, animated: Bool)

    @discardableResult
    func popToViewControllerType(_ viewController: UIViewControllerType, animated: Bool) -> [UIViewController]?

    @discardableResult
    func popToRootViewControllerType(animated: Bool) -> [UIViewControllerType]?
}

/**
 Protocol implementation of the `UIViewController` interface used in this framework
 */
public protocol UIViewControllerType: class {
    
    var definesPresentationContext: Bool {get set}
    
    var modalTransitionStyle: UIModalTransitionStyle { get set }
    
    var modalPresentationStyle: UIModalPresentationStyle { get set }
    
    func present(_ viewControllerToPresent: UIViewControllerType, animated: Bool, completion: (() -> Void)?)
    
    var navigationControllerType: UINavigationControllerType? { get }
    
    var presentedViewControllerType: UIViewControllerType? { get }
    
    func dismiss(animated: Bool, completion: (() -> Void)?)
    
    var tabBarItem: UITabBarItem! { get set }
    
}

public protocol UITabBarControllerType: UIViewControllerType {
    
    func setViewControllers(_ viewControllers: [UIViewControllerType])
    
}

extension UIViewControllerType {
    func present(_ viewControllerToPresent: UIViewControllerType, animated: Bool) {
        self.present(viewControllerToPresent, animated: animated, completion: nil)
    }
    
    func dismiss(animated: Bool) {
        self.dismiss(animated: animated, completion: nil)
    }
}

extension UINavigationController: UINavigationControllerType {
    public func pushViewControllerType(_ viewController: UIViewControllerType, animated: Bool) {
        pushViewController(viewController as! UIViewController, animated: animated)
    }

    public func popToViewControllerType(_ viewController: UIViewControllerType, animated: Bool) -> [UIViewController]? {
        return popToViewController(viewController as! UIViewController, animated: animated)
    }
    
    public func popToRootViewControllerType(animated: Bool) -> [UIViewControllerType]? {
        return self.popToRootViewController(animated: animated)
    }
}

extension UIViewController: UIViewControllerType {
    
    public var presentedViewControllerType: UIViewControllerType? {
        return self.presentedViewController
    }
    
    public func present(_ viewControllerToPresent: UIViewControllerType, animated: Bool, completion: (() -> Void)?) {
        
        guard let vc = viewControllerToPresent as? UIViewController else {
            return
        }
        self.present(vc, animated: animated, completion: completion)
    }
    
    public var navigationControllerType: UINavigationControllerType? {
        return navigationController
    }
    
}

extension UITabBarController: UITabBarControllerType {
    public func setViewControllers(_ viewControllers: [UIViewControllerType]) {
        self.setViewControllers(viewControllers.compactMap { $0 as? UIViewController},
                                animated: false)
    }
}
