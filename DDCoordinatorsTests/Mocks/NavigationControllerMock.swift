//
//  NavigationControllerMock.swift
//  DDCoordinatorsTests
//
//  Created by Dan Dunnington on 15/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit
@testable import DDCoordinators

class NavigationControllerMock: ViewControllerMock, UINavigationControllerType {
    
    // MARK: - Recording Variables
    var lastPushViewControllerType: PushControllerType?
    
    var lastPopToViewControllerType: PopToViewControllerType?
    
    // MARK: - Helper Interface
    var viewControllers: [UIViewControllerType] = []
    
    // MARK: - Conformance
    func pushViewControllerType(_ viewController: UIViewControllerType, animated: Bool) {
        
        viewControllers.append(viewController)
        
        lastPushViewControllerType = PushControllerType(viewController: viewController, animated: animated)
    }
    
    func popToViewControllerType(_ viewController: UIViewControllerType, animated: Bool) -> [UIViewController]? {
        lastPopToViewControllerType = PopToViewControllerType(viewController: viewController, animated: animated)
        return []
    }
    
    struct PushControllerType {
        let viewController: UIViewControllerType
        let animated: Bool
    }
    
    struct PopToViewControllerType {
        let viewController: UIViewControllerType
        let animated: Bool
    }
}
