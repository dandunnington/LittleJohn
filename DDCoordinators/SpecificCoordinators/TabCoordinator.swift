//
//  TabCoordinator.swift
//  LittleJohn
//
//  Created by Dan Dunnington on 23/02/2020.
//  Copyright © 2020 Dan Dunnington. All rights reserved.
//

import Foundation
import UIKit

/**
    A coordinator wrapper for a tab controller
 */
open class TabCoordinator: Coordinator<NoReturn> {
    
    // MARK: - Public Interface
    
    /// Override this to create a child coordinators
    open func createChildren() -> [Tab] {
        fatalError("createChildren must be override and super must not be called")
    }
    
    /// Creates a the `UITabBarControllerType` that's added to the view hierachy
    ///
    /// Override this to customise the tab bar appearance
    open func createTabBarController() -> UITabBarControllerType {
        return NoNavBarTabController()
    }
    
    // MARK: - Overrides
    override func displayUI(animated: Bool) {
        super.displayUI(animated: animated)
        
        // create child coordinators
        let children = createChildren()
        let tabBarController = createTabBarController()
        
        guard let strongNavController = self._strongNavigationController else {
            return
        }
        
        let viewControllers = children.compactMap { child -> UIViewControllerType? in
            self.startChildType(animated: false, child.coordinator)
            guard let vc = child.coordinator._strongNavigationController else { return nil }
            vc.tabBarItem = child.tabBarItem
            return vc
        }
        
        tabBarController.setViewControllers(viewControllers)
        strongNavController.pushViewControllerType(tabBarController, animated: false)
        
        // save weak reference to the bar bar controller
        self.tabBarController = tabBarController
        
        for child in children {
            child.coordinator.deallocateStrongNavController()
        }
    }
    
    // MARK: - Private Interface
    private weak var tabBarController: UITabBarControllerType?
    
    // MARK: - Supporting Structures
    /// Configuration objecs for tabs on the `TabCoordinator`
    public class Tab {
        let coordinator: CoordinatorType
        let tabBarItem: UITabBarItem
        
        public init(coordinator: CoordinatorType, tabBarItem: UITabBarItem) {
            self.coordinator = coordinator
            self.tabBarItem = tabBarItem
        }
    }
}
